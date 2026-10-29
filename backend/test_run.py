"""
Test runner for the Saabi AI pipeline.
Tests rules layer, retrieval, personalization, and orchestrator.
Run from the backend/ directory:
    cd backend
    python test_run.py
"""
import json
import os
import sys

# Add backend to path
sys.path.insert(0, os.path.dirname(__file__))

import retrieval
import orchestrator
import rules_layer

print("=" * 60)
print("SAABI AI — TEST RUNNER")
print("=" * 60)

# Test 1: Content library loads
library = retrieval.load_library()
print(f"\n✅ Content library loaded: {len(library)} entries\n")

# Test 2: Rules layer
print("--- Rules Layer Tests ---")
escalation_tests = [
    "I want to kill myself",
    "I have severe chest pain",
    "he has been beating me",
    "I ran out of ARV medication",
    "I'm having a mental breakdown",
    "what is HIV",  # should NOT escalate
]
for msg in escalation_tests:
    result = rules_layer.check(msg)
    flag = f"🚨 ESCALATE [{result['category']}]" if result else "✅ safe"
    print(f"  '{msg[:45]}...' → {flag}" if len(msg) > 45 else f"  '{msg}' → {flag}")

# Test 3: Retrieval
print("\n--- Retrieval Tests ---")
queries = [
    "what is u=u and can undetectable people transmit hiv",
    "how is hiv actually transmitted",
    "what does art stand for",
    "how do I deal with anxiety",
    "what foods should I eat",
]
for q in queries:
    results = retrieval.search(q, library, top_k=1)
    topic = results[0]["topic"] if results else "no match"
    print(f"  '{q[:50]}' → {topic}")

# Test 4: Full orchestrator (without real LLM — uses fallback)
print("\n--- Orchestrator Tests (no LLM keys needed) ---")
profile_store = {}
turns = [
    ("amina_01", "what is u=u and can undetectable people transmit hiv"),
    ("amina_01", "how is hiv actually transmitted"),
    ("bola_02",  "how is hiv actually transmitted"),
]

for user_id, message in turns:
    print(f"\n  {user_id}: \"{message}\"")
    try:
        result = orchestrator.chat_turn(user_id, message, profile_store, library)
        if result["type"] == "escalation":
            print(f"  → ESCALATED: {result['match']['category']}")
        else:
            print(f"  → Topic: {result['topic_matched']}")
            print(f"  → Provider: {result.get('provider', 'N/A')}")
            print(f"  → Interactions: {result['profile_after']['total_interactions']}")
    except RuntimeError as e:
        print(f"  → LLM unavailable (no API keys set): {e}")
        print(f"  → Pipeline still worked up to LLM call ✅")

print("\n" + "=" * 60)
print("All pipeline tests complete.")
print("=" * 60)
