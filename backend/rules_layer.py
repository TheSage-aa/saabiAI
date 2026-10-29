"""
Deterministic safety layer. Runs BEFORE retrieval / personalization / LLM.

Rules are keyword/phrase pattern checks grouped by escalation category.
When a rule fires, the LLM is NOT called -- the user is immediately routed
to human support resources appropriate for their situation.

Categories covered:
  - self_harm         : suicidal ideation, self-injury
  - medical_emergency  : chest pain, difficulty breathing, seizure, etc.
  - abuse_disclosure   : sexual assault, domestic violence, abuse
  - hiv_crisis         : ART stock-out, stopped medication, PEP urgency
  - mental_crisis      : severe psychological distress, psychosis

Each pattern list uses lowercase strings. Matching is case-insensitive,
word-boundary based -- see check() for why plain substring search isn't
used.

NOTE (2026-10-29): added a handful of synonym phrasings to self_harm.
This is NOT new clinical/triage logic -- the category, its resource_key,
and its escalation behavior are unchanged. The content library
(content-library/mental_health.json) already ships the literal example
question "I want give up" as something Saabi should recognize, but that
exact phrase wasn't in this file's self_harm patterns, so it would have
fallen through to a normal Q&A answer instead of the human-escalation
path -- the opposite of what the project brief requires for crisis
language. These additions just make the existing, already-approved rule
catch the phrasing the project's own content already expects it to
catch. No new category, resource, or escalation behavior was invented.
"""

import re

# ---------------------------------------------------------------------------
# Rule definitions
# ---------------------------------------------------------------------------
RULES = [
    {
        "category": "self_harm",
        "severity": "critical",
        "patterns": [
            "want to die", "wants to die", "want to kill myself",
            "kill myself", "end my life", "take my life", "suicidal",
            "suicide", "self harm", "self-harm", "cutting myself",
            "hurt myself", "don't want to live", "no reason to live",
            "rather be dead", "wish i was dead", "wish i were dead",
            "not worth living", "tired of living", "can't go on",
            "cannot go on", "overdose on purpose", "i give up on life",
            # Added 2026-10-29: synonym phrasings of the same already-approved
            # self_harm category (see note above) -- not a new rule/category.
            "i want give up", "i want to give up", "want give up",
            "giving up on life", "feel like giving up",
            "no point in living", "no point living",
            "better off dead", "life is not worth it",
        ],
        "action": "escalate_to_human",
        "resource_key": "mental_health_crisis",
    },
    {
        "category": "medical_emergency",
        "severity": "critical",
        "patterns": [
            "chest pain", "chest tightness", "can't breathe",
            "cannot breathe", "difficulty breathing", "shortness of breath",
            "heart attack", "stroke", "seizure", "fitting", "convulsion",
            "unconscious", "passed out", "fainting", "fainted",
            "bleeding heavily", "bleeding badly", "won't stop bleeding",
            "poisoning", "swallowed poison", "drug overdose",
            "overdosed", "coughing blood", "vomiting blood",
            "severe pain", "excruciating pain", "paralyzed", "paralysed",
        ],
        "action": "escalate_to_human",
        "resource_key": "medical_emergency",
    },
    {
        "category": "abuse_disclosure",
        "severity": "critical",
        "patterns": [
            "being abused", "he beats me", "she beats me",
            "he hits me", "she hits me", "domestic violence",
            "sexual assault", "was raped", "raped me", "someone raped",
            "rape", "molested", "molestation", "sexual abuse",
            "he forced me", "she forced me", "forced to have sex",
            "non-consensual", "touched me without", "abusing me",
            "physical abuse", "emotional abuse", "coerced",
        ],
        "action": "escalate_to_human",
        "resource_key": "abuse_support",
    },
    {
        "category": "hiv_crisis",
        "severity": "urgent",
        "patterns": [
            "ran out of arv", "ran out of art", "out of medication",
            "can't get my drugs", "cannot get my drugs",
            "drugs finished", "medicine finished", "stock out",
            "stockout", "no more arv", "stopped taking arv",
            "stopped my arv", "stopped art", "stopped taking art",
            "missed many doses", "missed a lot of doses",
            "need pep", "post exposure prophylaxis", "exposed to hiv",
            "possible hiv exposure", "condom broke",
            "needle stick", "needlestick",
        ],
        "action": "escalate_to_human",
        "resource_key": "hiv_crisis",
    },
    {
        "category": "mental_crisis",
        "severity": "urgent",
        "patterns": [
            "breaking down", "mental breakdown", "nervous breakdown",
            "can't cope anymore", "cannot cope anymore",
            "everything is hopeless", "completely hopeless",
            "losing my mind", "going insane", "going crazy",
            "hearing voices", "seeing things", "hallucinating",
            "paranoid", "psychosis", "psychotic",
            "severe depression", "deeply depressed",
            "don't want to get out of bed", "stopped eating",
            "not eating for days", "not sleeping for days",
        ],
        "action": "escalate_to_human",
        "resource_key": "mental_health_crisis",
    },
]


def _normalize(text: str) -> str:
    """Lowercase and collapse whitespace for reliable matching."""
    return " ".join(text.lower().split())


def check(message_text: str) -> dict | None:
    """
    Returns None if the message is safe to continue to the LLM pipeline.
    Returns a dict describing the match if a safety rule fires:

    {
        "category":     "self_harm",
        "severity":     "critical",
        "trigger":      "kill myself",
        "action":       "escalate_to_human",
        "resource_key": "mental_health_crisis"
    }
    """
    normalized = _normalize(message_text)

    for rule in RULES:
        for pattern in rule["patterns"]:
            # Word-boundary match instead of plain substring: a plain
            # "pattern in normalized" check meant short patterns like
            # "rape" false-positived inside unrelated words (e.g. "grape"),
            # which would wrongly route a harmless message into a crisis
            # escalation. \b keeps multi-word phrases working exactly as
            # before while fixing this for single-word patterns.
            if re.search(r"\b" + re.escape(pattern) + r"\b", normalized):
                return {
                    "category": rule["category"],
                    "severity": rule["severity"],
                    "trigger": pattern,
                    "action": rule["action"],
                    "resource_key": rule["resource_key"],
                }

    return None
