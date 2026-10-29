"""
Loads every content-library/*.json file and does simple keyword matching
against each entry's question_patterns. No external dependencies -- this is
meant to be legible and swappable later (e.g. for embeddings-based search)
without changing the interface other modules rely on.
"""
import json
import os
import re

CONTENT_LIBRARY_DIR = os.path.join(os.path.dirname(__file__), "..", "content-library")

# Common words that create false-positive overlap between unrelated
# questions ("what does X mean" vs "what does Y stand for"). Excluded from
# matching so overlap reflects actual topic words, not question grammar.
STOPWORDS = {
    "a", "an", "the", "is", "are", "was", "were", "what", "when", "where",
    "who", "why", "how", "does", "do", "did", "can", "could", "should",
    "would", "will", "i", "you", "it", "this", "that", "of", "to", "in",
    "on", "for", "and", "or", "my", "your", "me", "about", "if", "with",
}


def _tokenize(text):
    tokens = set(re.findall(r"[a-z0-9]+", text.lower()))
    return tokens - STOPWORDS


def load_library(directory=CONTENT_LIBRARY_DIR):
    """Returns a flat list of entries, each tagged with its source topic file."""
    entries = []
    if not os.path.exists(directory):
        return entries
    for filename in sorted(os.listdir(directory)):
        if not filename.endswith(".json"):
            continue
        with open(os.path.join(directory, filename), "r", encoding="utf-8") as f:
            data = json.load(f)
        topic = data.get("topic", filename)
        for entry in data.get("entries", []):
            entry = dict(entry)
            entry["topic"] = topic
            entries.append(entry)
    return entries


def search(query, library, top_k=1):
    """
    Scores each entry by token overlap between the query and its
    question_patterns, returns the top_k matches with a score > 0.
    Ties broken by entry order (stable).
    """
    query_tokens = _tokenize(query)
    scored = []
    for entry in library:
        pattern_tokens = set()
        for pattern in entry.get("question_patterns", []):
            pattern_tokens |= _tokenize(pattern)
        overlap = len(query_tokens & pattern_tokens)
        if overlap > 0:
            scored.append((overlap, entry))
    scored.sort(key=lambda pair: pair[0], reverse=True)
    return [entry for score, entry in scored[:top_k]]
