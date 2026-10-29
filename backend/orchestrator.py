"""
One chat turn, end to end: rules layer -> retrieval -> personalization ->
LLM router (Claude / Gemini / Perplexity with automatic failover).
"""
import rules_layer
import retrieval
import personalization
import llm_router


def chat_turn(user_id, message, profile_store, library, history=None):
    history = history or []

    # 1. Deterministic safety check, always runs first.
    match = rules_layer.check(message)
    if match:
        return {
            "type": "escalation",
            "detail": "Routing to human-reviewed escalation path.",
            "match": match,
        }

    # 2. Grounded retrieval against the content library.
    results = retrieval.search(message, library, top_k=1)
    matched_entry = results[0] if results else None
    topic = matched_entry["topic"] if matched_entry else None

    # 3. Personalization directive (built BEFORE updating the profile).
    profile = personalization.get_or_create_profile(profile_store, user_id)
    directive = personalization.build_personalization_directive(profile, topic)

    # 4. Record this interaction for next time.
    personalization.record_interaction(profile, topic)

    # 5. Build system prompt
    if matched_entry:
        system_prompt = (
            "You are Saabi, a warm, plain-language health companion for young "
            "people in Nigeria. Answer using ONLY the grounded fact below. "
            f"\n\nGrounded fact: {matched_entry['answer']}"
            f"\nSource(s): {', '.join(matched_entry.get('sources', []))}"
            f"\n\nPersonalization guidance: {directive}"
        )
    else:
        system_prompt = (
            "You are Saabi, a warm, plain-language health companion for young "
            "people in Nigeria. No grounded entry matched — stay general and "
            "non-clinical. Encourage a more specific health question."
            f"\n\nPersonalization guidance: {directive}"
        )

    # 6. Route to best available LLM
    messages = history + [{"role": "user", "content": message}]
    llm_result = llm_router.generate(system_prompt, messages, message)

    return {
        "type": "reply",
        "topic_matched": topic,
        "personalization_directive": directive,
        "reply": llm_result.text,
        "provider": llm_result.provider,
        "citations": llm_result.citations,
        "profile_after": {
            "total_interactions": profile.total_interactions,
            "topics_engaged": dict(profile.topics_engaged),
        },
    }
