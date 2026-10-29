"""
JSON file-based persistent storage for Saabi AI user profiles.
Replaces the in-memory profile_store dict so profiles survive server restarts.

Storage layout:
    data/profiles/{user_id}.json

Each file contains:
{
    "user_id": "...",
    "topics_engaged": { "hiv_basics": 3, "mental_health": 1 },
    "total_interactions": 4,
    "conversation_history": [
        { "role": "user", "content": "..." },
        { "role": "assistant", "content": "..." }
    ]
}

Thread safety: atomic write via temp file + rename to prevent corruption.
"""
import json
import os
import tempfile

from personalization import UserProfile

DATA_DIR = os.path.join(os.path.dirname(__file__), "data", "profiles")
MAX_HISTORY = 20  # rolling window of messages kept per user


def _profile_path(user_id: str) -> str:
    os.makedirs(DATA_DIR, exist_ok=True)
    # Sanitize user_id to safe filename characters
    safe_id = "".join(c if c.isalnum() or c in "-_" else "_" for c in user_id)
    return os.path.join(DATA_DIR, f"{safe_id}.json")


def load_profile(user_id: str) -> tuple[UserProfile, list]:
    """
    Returns (UserProfile, conversation_history).
    Creates a fresh profile if none exists yet.
    """
    path = _profile_path(user_id)
    if not os.path.exists(path):
        return UserProfile(user_id=user_id), []

    with open(path, "r", encoding="utf-8") as f:
        data = json.load(f)

    profile = UserProfile(
        user_id=user_id,
        topics_engaged=data.get("topics_engaged", {}),
        total_interactions=data.get("total_interactions", 0),
    )
    history = data.get("conversation_history", [])
    return profile, history


def save_profile(profile: UserProfile, history: list) -> None:
    """
    Atomically writes the profile + trimmed conversation history to disk.
    """
    path = _profile_path(profile.user_id)
    trimmed_history = history[-MAX_HISTORY:]  # keep only the last N messages

    data = {
        "user_id": profile.user_id,
        "topics_engaged": dict(profile.topics_engaged),
        "total_interactions": profile.total_interactions,
        "conversation_history": trimmed_history,
    }

    # Atomic write: write to temp file then rename
    dir_name = os.path.dirname(path)
    with tempfile.NamedTemporaryFile(
        "w", encoding="utf-8", dir=dir_name, delete=False, suffix=".tmp"
    ) as tmp:
        json.dump(data, tmp, indent=2, ensure_ascii=False)
        tmp_path = tmp.name

    os.replace(tmp_path, path)


def append_to_history(history: list, role: str, content: str) -> list:
    """
    Appends a message to the history list and returns the updated list.
    Trims to MAX_HISTORY entries automatically.
    """
    history.append({"role": role, "content": content})
    return history[-MAX_HISTORY:]
