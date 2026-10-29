"""
Intelligent LLM Router for Saabi AI.

Routes each query to the best available AI provider based on intent,
with automatic fallback if a provider fails (rate limit, quota, outage).

Provider roles:
  - Perplexity Sonar  : Research queries needing real-time data + citations
  - Claude Sonnet     : Empathetic, personal health conversations
  - Gemini Flash      : Fast general health knowledge, high-volume fallback

Fallback chains:
  Research  → Perplexity → Claude → Gemini
  Empathy   → Claude     → Gemini → Perplexity
  General   → Gemini     → Claude → Perplexity

All providers receive the same system prompt + message history.
The response is normalized to a plain string regardless of provider.
"""

import os
import logging

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Intent detection
# ---------------------------------------------------------------------------

RESEARCH_KEYWORDS = {
    "latest", "recent", "new study", "new research", "studies show",
    "research says", "evidence", "statistics", "data", "percentage",
    "prevalence", "incidence", "published", "journal", "clinical trial",
    "systematic review", "meta-analysis", "2024", "2025", "2026",
    "globally", "worldwide", "according to who", "according to unaids",
    "what does research", "what do studies", "how many people",
    "rate of", "cases of",
}

EMPATHY_KEYWORDS = {
    "i feel", "i am scared", "i'm scared", "i'm worried", "i am worried",
    "anxious", "depressed", "lonely", "ashamed", "embarrassed",
    "afraid", "nervous", "confused", "lost", "overwhelmed",
    "don't know what to do", "help me", "i need support",
    "i'm struggling", "i am struggling", "emotionally", "crying",
    "stressed", "scared", "frightened", "hopeless", "helpless",
}


def _detect_intent(message: str) -> str:
    """Returns 'research', 'empathy', or 'general'."""
    lower = message.lower()
    if any(kw in lower for kw in RESEARCH_KEYWORDS):
        return "research"
    if any(kw in lower for kw in EMPATHY_KEYWORDS):
        return "empathy"
    return "general"


# ---------------------------------------------------------------------------
# Provider clients (lazy-loaded so missing keys don't crash import)
# ---------------------------------------------------------------------------

def _call_claude(system_prompt: str, messages: list, max_tokens: int = 500) -> str:
    import anthropic
    client = anthropic.Anthropic(api_key=os.environ["ANTHROPIC_API_KEY"])
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=max_tokens,
        system=system_prompt,
        messages=messages,
    )
    return "".join(
        block.text for block in response.content if block.type == "text"
    )


def _call_gemini(system_prompt: str, messages: list, max_tokens: int = 1000) -> str:
    """
    Calls Gemini via REST API directly — avoids SDK version compatibility issues.
    Tries multiple model names in order until one works.
    """
    import httpx

    api_key = os.environ["GOOGLE_API_KEY"]

    # Build Gemini-format contents from message history
    contents = []
    for msg in messages:
        role = "user" if msg["role"] == "user" else "model"
        contents.append({"role": role, "parts": [{"text": msg["content"]}]})

    payload = {
        "system_instruction": {"parts": [{"text": system_prompt}]},
        "contents": contents,
        "generationConfig": {
            "maxOutputTokens": max_tokens,
            "thinkingConfig": {"thinkingBudget": 0},  # disable thinking — prevents internal reasoning leaking into chat
        },
    }

    # Models confirmed available from this API key — ordered by quality
    models_to_try = [
        "gemini-3.8-flash",          # newest & fastest — confirmed available
        "gemini-3.7-flash",          # confirmed available
        "gemini-3.6-flash",          # confirmed available
        "gemini-3.5-flash",          # confirmed available
        "gemini-3.1-flash-lite",     # confirmed available
        "gemini-flash-latest",       # alias — confirmed available
        "gemini-3-flash-preview",    # confirmed available
        "gemma-4-31b-it",            # last resort fallback
    ]

    for model in models_to_try:
        url = (
            f"https://generativelanguage.googleapis.com/v1beta"
            f"/models/{model}:generateContent?key={api_key}"
        )
        try:
            resp = httpx.post(url, json=payload, timeout=30)
            if resp.status_code == 404:
                logger.warning(f"Gemini model '{model}' not found, trying next...")
                continue
            resp.raise_for_status()
            data = resp.json()
            # Collect ONLY the actual response parts — skip any "thought" parts
            # (thinking models include reasoning steps we don't want shown to users)
            parts = data["candidates"][0]["content"]["parts"]
            text = "\n".join(
                p["text"] for p in parts
                if "text" in p and not p.get("thought", False)
            ).strip()
            if not text:
                raise ValueError("Empty response after filtering thought parts")
            logger.info(f"Gemini responded using model: {model}")
            return text
        except (KeyError, IndexError) as e:
            logger.warning(f"Gemini model '{model}' response parse error: {e}")
            continue
        except httpx.HTTPStatusError as e:
            logger.warning(f"Gemini model '{model}' HTTP error: {e}")
            continue

    raise RuntimeError("All Gemini models failed.")


def _call_perplexity(system_prompt: str, messages: list, max_tokens: int = 800) -> tuple[str, list]:
    """Returns (reply_text, citations_list)."""
    import httpx, json

    headers = {
        "Authorization": f"Bearer {os.environ['PERPLEXITY_API_KEY']}",
        "Content-Type": "application/json",
    }
    payload = {
        "model": "llama-3.1-sonar-large-128k-online",
        "messages": [{"role": "system", "content": system_prompt}] + messages,
        "max_tokens": max_tokens,
        "return_citations": True,
    }
    resp = httpx.post(
        "https://api.perplexity.ai/chat/completions",
        headers=headers,
        json=payload,
        timeout=30,
    )
    resp.raise_for_status()
    data = resp.json()
    text = data["choices"][0]["message"]["content"]
    citations = data.get("citations", [])
    return text, citations


# ---------------------------------------------------------------------------
# Public interface
# ---------------------------------------------------------------------------

class LLMResponse:
    def __init__(self, text: str, provider: str, citations: list = None):
        self.text = text
        self.provider = provider
        self.citations = citations or []


def generate(
    system_prompt: str,
    messages: list,
    user_message: str = None,
) -> LLMResponse:
    """
    Routes the request to the best provider based on intent detection,
    falling back through the chain automatically on any error.

    Args:
        system_prompt : Saabi system prompt (includes personalization + grounded fact)
        messages      : Full conversation history in OpenAI format
                        [{"role": "user"|"assistant", "content": "..."}]
        user_message  : The latest user message (for intent detection).
                        If None, uses the last message in `messages`.

    Returns:
        LLMResponse with .text, .provider, and .citations
    """
    if user_message is None:
        user_message = messages[-1]["content"] if messages else ""

    intent = _detect_intent(user_message)
    logger.info(f"Intent detected: {intent}")

    # Define provider call order based on intent
    if intent == "research":
        chain = [
            ("perplexity", lambda: _call_perplexity(system_prompt, messages)),
            ("claude",     lambda: (_call_claude(system_prompt, messages), [])),
            ("gemini",     lambda: (_call_gemini(system_prompt, messages), [])),
        ]
    elif intent == "empathy":
        chain = [
            ("claude",     lambda: (_call_claude(system_prompt, messages), [])),
            ("gemini",     lambda: (_call_gemini(system_prompt, messages), [])),
            ("perplexity", lambda: _call_perplexity(system_prompt, messages)),
        ]
    else:  # general
        chain = [
            ("gemini",     lambda: (_call_gemini(system_prompt, messages), [])),
            ("claude",     lambda: (_call_claude(system_prompt, messages), [])),
            ("perplexity", lambda: _call_perplexity(system_prompt, messages)),
        ]

    last_error = None
    for provider_name, call_fn in chain:
        # Skip providers whose API key is not configured
        key_map = {
            "claude":     "ANTHROPIC_API_KEY",
            "gemini":     "GOOGLE_API_KEY",
            "perplexity": "PERPLEXITY_API_KEY",
        }
        if not os.environ.get(key_map[provider_name]):
            logger.warning(f"Skipping {provider_name}: API key not set")
            continue

        try:
            result = call_fn()
            # Normalize: all callers return (text, citations) tuple
            if isinstance(result, tuple):
                text, citations = result
            else:
                text, citations = result, []

            logger.info(f"Response from {provider_name} ({len(text)} chars)")
            return LLMResponse(text=text, provider=provider_name, citations=citations)

        except Exception as exc:
            logger.warning(f"{provider_name} failed: {exc}. Trying next provider.")
            last_error = exc
            continue

    # All providers failed
    raise RuntimeError(
        f"All LLM providers failed. Last error: {last_error}"
    )
