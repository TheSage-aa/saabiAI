"""
Standalone diagnostic — writes results to test_results.json
Run: python diagnose.py
"""
import sys, json, os

out = {}

# Python version
out["python"] = sys.version[:30]

# Imports
try:
    import retrieval
    import rules_layer
    import personalization
    out["imports"] = "ALL OK"
except Exception as e:
    out["imports"] = f"FAILED: {e}"

# Content library
try:
    lib = retrieval.load_library()
    out["library_entries"] = len(lib)
    out["topics"] = sorted(set(e["topic"] for e in lib))
except Exception as e:
    out["library"] = f"FAILED: {e}"

# Rules layer tests
try:
    tests = [
        ("I want to kill myself",     "self_harm"),
        ("I have chest pain",          "medical_emergency"),
        ("he beats me every night",    "abuse_disclosure"),
        ("I ran out of ARV",           "hiv_crisis"),
        ("I am having a mental breakdown", "mental_crisis"),
        ("what is HIV",                None),  # should NOT escalate
    ]
    rules_results = []
    for msg, expected_cat in tests:
        r = rules_layer.check(msg)
        got = r["category"] if r else None
        rules_results.append({
            "message":  msg[:40],
            "expected": expected_cat,
            "got":      got,
            "pass":     got == expected_cat,
        })
    out["rules_tests"] = rules_results
    out["rules_pass"] = all(t["pass"] for t in rules_results)
except Exception as e:
    out["rules"] = f"FAILED: {e}"

# Retrieval tests
try:
    lib = retrieval.load_library()
    retrieval_results = []
    for q in ["what is hiv", "how does art work", "anxiety help", "nutrition food"]:
        r = retrieval.search(q, lib, top_k=1)
        retrieval_results.append({
            "query": q,
            "topic": r[0]["topic"] if r else "NO MATCH",
        })
    out["retrieval_tests"] = retrieval_results
except Exception as e:
    out["retrieval"] = f"FAILED: {e}"

# Write results
path = os.path.join(os.path.dirname(__file__), "test_results.json")
with open(path, "w", encoding="utf-8") as f:
    json.dump(out, f, indent=2)

print(f"Done. Results written to {path}")
print(json.dumps(out, indent=2))
