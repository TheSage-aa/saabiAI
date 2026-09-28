"""
FastAPI deployment wrapper for Saabi AI.

Endpoints:
  POST /chat        — main chat endpoint
  GET  /health      — health check
  GET  /profile/{user_id} — fetch current user profile stats

Changes from original main.py:
  - CORS enabled for frontend access
  - profile_store replaced with JSON file storage (storage.py)
  - LLM call replaced with intelligent 3-provider router (llm_router.py)
  - Multi-turn conversation history passed to LLM
  - Citations returned for research responses (Perplexity)
  - Escalation responses now include resource_key for frontend to display contacts
"""
import os
import logging
from dotenv import load_dotenv

# Load API keys from .env file in the backend directory
load_dotenv(os.path.join(os.path.dirname(__file__), ".env"))
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pydantic import BaseModel

import retrieval
import personalization
import rules_layer
import storage
import llm_router

# Path to the frontend folder (one level up from backend/)
FRONTEND_DIR = os.path.join(os.path.dirname(__file__), "..", "frontend")

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="Saabi AI", version="2.0.0")

# CORS — allow the frontend (any origin in dev, restrict in prod)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Content library loaded once at startup
library = retrieval.load_library()
logger.info(f"Loaded {len(library)} content-library entries.")


# ---------------------------------------------------------------------------
# Request / Response models
# ---------------------------------------------------------------------------

class ChatRequest(BaseModel):
    user_id: str
    message: str


class ChatResponse(BaseModel):
    reply: str
    topic_matched: str | None
    escalated: bool
    resource_key: str | None       # e.g. "mental_health_crisis" when escalated
    provider: str | None           # which LLM responded
    citations: list[str]           # source URLs (Perplexity research queries)


# ---------------------------------------------------------------------------
# Emergency resource contact blocks (shown in frontend escalation panel)
# ---------------------------------------------------------------------------
ESCALATION_MESSAGES = {
    "mental_health_crisis": (
        "I hear you, and I want you to know you are not alone. "
        "Please reach out to a mental health professional right now — "
        "you deserve real support from a real human who can help. "
        "The Mentally Aware Nigeria Initiative (MANI) helpline is "
        "available at 08091116264. You matter."
    ),
    "medical_emergency": (
        "This sounds like it could be a medical emergency. "
        "Please call 112 (Nigeria Emergency) or go to your nearest "
        "hospital emergency room immediately. Do not wait. "
        "If you are in Lagos, you can also call 767 (LASEMA)."
    ),
    "abuse_support": (
        "What you are sharing takes courage, and I want you to know "
        "you are not to blame. Please reach out to the "
        "NAPTIP hotline: 0800-NAPTIP-1 (0800-627847-1) or "
        "Project Alert on Gender-Based Violence: 08052001111. "
        "You deserve to be safe."
    ),
    "hiv_crisis": (
        "Access to your medication is critical — missing ART can "
        "seriously affect your health. Please visit your nearest "
        "ART clinic or PEPFAR-supported site immediately. "
        "You can also call the NACA helpline: 0800-235-6682 (free). "
        "They can help you locate the nearest facility with drug supply."
    ),
}


# ---------------------------------------------------------------------------
# Chat endpoint
# ---------------------------------------------------------------------------

@app.post("/chat", response_model=ChatResponse)
def chat(req: ChatRequest):
    # 1. Safety rules — always run first, before anything else
    match = rules_layer.check(req.message)
    if match:
        resource_key = match.get("resource_key", "medical_emergency")
        reply = ESCALATION_MESSAGES.get(
            resource_key,
            "Please reach out to a healthcare professional immediately. You are not alone.",
        )
        return ChatResponse(
            reply=reply,
            topic_matched=None,
            escalated=True,
            resource_key=resource_key,
            provider=None,
            citations=[],
        )

    # 2. Load user profile + conversation history from disk
    profile, history = storage.load_profile(req.user_id)

    # 3. Retrieval — find best grounded content-library match
    results = retrieval.search(req.message, library, top_k=1)
    matched_entry = results[0] if results else None
    topic = matched_entry["topic"] if matched_entry else None

    # 4. Personalization directive (built BEFORE recording this interaction)
    directive = personalization.build_personalization_directive(profile, topic)

    # 5. Record this interaction
    personalization.record_interaction(profile, topic)

    # 6. Build full knowledge base — give Saabi access to ALL stored health facts
    def build_knowledge_base(lib):
        topics = {}
        for entry in lib:
            t = entry["topic"]
            if t not in topics:
                topics[t] = []
            topics[t].append(entry)
        lines = ["=== SAABI HEALTH KNOWLEDGE BASE ===\n"]
        for topic, entries in topics.items():
            lines.append(f"[{topic.replace('_', ' ').upper()}]")
            for e in entries:
                lines.append(f"  Fact: {e['answer']}")
                lines.append(f"  Sources: {', '.join(e.get('sources', []))}")
            lines.append("")
        return "\n".join(lines)

    knowledge_base = build_knowledge_base(library)
    best_match_note = (
        f"\nBEST MATCH for this question (topic: {matched_entry['topic']}):\n"
        f"{matched_entry['answer']}\n"
        if matched_entry else ""
    )

    system_prompt = (
        "You are Saabi, a warm, caring health companion for young people in Nigeria.\n"
        "Speak in plain, friendly, non-judgmental language.\n\n"

        "🌍 LANGUAGE RULE (very important):\n"
        "Detect the language the user is writing in and ALWAYS reply in that same language.\n"
        "Supported languages include:\n"
        "  - English (standard)\n"
        "  - Nigerian Pidgin (e.g. 'abeg', 'wetin', 'na', 'dey', 'abi')\n"
        "  - Yoruba\n"
        "  - Igbo\n"
        "  - Hausa\n"
        "  - French\n"
        "If the user mixes languages (e.g. Pidgin + English), match their style.\n"
        "Never switch the user to a language they did not use.\n\n"

        "HEALTH RULES:\n"
        "1. Answer health questions using the KNOWLEDGE BASE below — always prefer it over general knowledge.\n"
        "2. If the answer is in the knowledge base, use it accurately.\n"
        "3. If not covered, be honest and suggest consulting a health professional.\n"
        "4. Never give medical diagnoses or prescriptions.\n"
        "5. Keep responses warm, clear, and complete — never cut off mid-sentence.\n"
        f"{best_match_note}\n"
        f"{knowledge_base}\n"
        f"Personalization guidance: {directive}"
    )

    # 7. Build messages array (history + current message)
    messages = history + [{"role": "user", "content": req.message}]

    # 8. Route to best LLM provider (with automatic failover)
    try:
        llm_result = llm_router.generate(
            system_prompt=system_prompt,
            messages=messages,
            user_message=req.message,
        )
    except RuntimeError as exc:
        logger.error(f"All LLM providers failed: {exc}")
        raise HTTPException(status_code=503, detail="AI service temporarily unavailable. Please try again.")

    # 9. Save updated profile + history to disk
    updated_history = storage.append_to_history(history, "user", req.message)
    updated_history = storage.append_to_history(updated_history, "assistant", llm_result.text)
    storage.save_profile(profile, updated_history)

    return ChatResponse(
        reply=llm_result.text,
        topic_matched=topic,
        escalated=False,
        resource_key=None,
        provider=llm_result.provider,
        citations=llm_result.citations,
    )


# ---------------------------------------------------------------------------
# Utility endpoints
# ---------------------------------------------------------------------------

@app.get("/health")
def health():
    return {"status": "ok", "library_entries": len(library)}


@app.get("/profile/{user_id}")
def get_profile(user_id: str):
    profile, history = storage.load_profile(user_id)
    return {
        "user_id": user_id,
        "total_interactions": profile.total_interactions,
        "topics_engaged": dict(profile.topics_engaged),
        "most_engaged_topic": profile.most_engaged_topic,
        "history_length": len(history),
    }


# ---------------------------------------------------------------------------
# Serve frontend — MUST be mounted last so API routes take priority
# ---------------------------------------------------------------------------

@app.get("/")
def serve_root():
    """Redirect root to the frontend index.html"""
    return FileResponse(os.path.join(FRONTEND_DIR, "index.html"))

# Mount frontend static files (css, js, images)
if os.path.exists(FRONTEND_DIR):
    app.mount("/", StaticFiles(directory=FRONTEND_DIR, html=True), name="frontend")
    logger.info(f"Frontend served at http://localhost:8000")
else:
    logger.warning(f"Frontend directory not found at {FRONTEND_DIR}")
