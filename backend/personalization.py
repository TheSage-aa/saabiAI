"""
Personalization based on topic-category engagement, deliberately NOT on
stored conversation content. See ai-service/README.md for why.

A "store" here is just a dict of user_id -> profile for this demo. In a real
deployment this is a Postgres table (see schema note in README).
"""
from dataclasses import dataclass, field
from typing import Dict


@dataclass
class UserProfile:
    user_id: str
    topics_engaged: Dict[str, int] = field(default_factory=dict)
    total_interactions: int = 0

    @property
    def is_returning(self):
        return self.total_interactions > 0

    @property
    def most_engaged_topic(self):
        if not self.topics_engaged:
            return None
        return max(self.topics_engaged, key=self.topics_engaged.get)


def get_or_create_profile(store, user_id):
    if user_id not in store:
        store[user_id] = UserProfile(user_id=user_id)
    return store[user_id]


def record_interaction(profile, topic):
    if topic:
        profile.topics_engaged[topic] = profile.topics_engaged.get(topic, 0) + 1
    profile.total_interactions += 1


def build_personalization_directive(profile, current_topic):
    """
    Returns a short instruction string meant to go into the LLM's system
    prompt -- not a canned reply, just guidance on tone/pacing/framing.
    """
    if not profile.is_returning:
        return (
            "This is this user's first interaction with Saabi AI. Use a warm, "
            "welcoming, foundational tone -- don't assume prior knowledge, and "
            "don't reference a history they don't have yet."
        )

    times_on_topic = profile.topics_engaged.get(current_topic, 0)
    if times_on_topic > 0:
        return (
            f"This user has engaged with this topic ({current_topic}) "
            f"{times_on_topic} time(s) before, across {profile.total_interactions} "
            "total interactions. You can build on likely prior context and "
            "move a bit faster past the absolute basics -- but never assume "
            "specifics they haven't actually told you in this conversation."
        )

    return (
        f"This is a returning user ({profile.total_interactions} prior "
        f"interactions, mostly around '{profile.most_engaged_topic}') asking "
        "about a new topic for them. Treat this specific topic as new to "
        "them, but you can use a slightly more familiar, less first-time tone "
        "overall since they already know how Saabi AI works."
    )
