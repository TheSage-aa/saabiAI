"""
Gemini key diagnostic — lists ALL available models for your key,
then tries to chat with the best one.

Run from the backend folder:
    python test_gemini.py
"""
import os, json

# Load .env manually
env_path = os.path.join(os.path.dirname(__file__), ".env")
if os.path.exists(env_path):
    with open(env_path) as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#") and "=" in line:
                k, v = line.split("=", 1)
                os.environ[k.strip()] = v.strip()

api_key = os.environ.get("GOOGLE_API_KEY", "")
if not api_key:
    print("ERROR: GOOGLE_API_KEY is not set in your .env file!")
    exit(1)

print(f"Key loaded: {api_key[:10]}...{api_key[-4:]}")
print(f"Key format: {'Old AIza format' if api_key.startswith('AIza') else 'Different format: ' + api_key[:5]}")
print()

try:
    import httpx
except ImportError:
    print("ERROR: httpx not installed. Run: pip install httpx")
    exit(1)

# -------------------------------------------------------
# STEP 1: List ALL models available for this key
# -------------------------------------------------------
print("=" * 55)
print("STEP 1: Listing all models your API key can access...")
print("=" * 55)

list_url = f"https://generativelanguage.googleapis.com/v1beta/models?key={api_key}"
try:
    resp = httpx.get(list_url, timeout=15)
    print(f"HTTP Status: {resp.status_code}")

    if resp.status_code == 200:
        data = resp.json()
        models = data.get("models", [])
        print(f"\nFound {len(models)} available models:\n")
        gemini_models = []
        for m in models:
            name = m.get("name", "").replace("models/", "")
            supported = m.get("supportedGenerationMethods", [])
            if "generateContent" in supported:
                print(f"  CHAT OK  --> {name}")
                gemini_models.append(name)
            else:
                print(f"  no chat  --> {name}")
    elif resp.status_code == 400:
        print(f"\nERROR 400: Bad request")
        print(f"Response: {resp.text[:300]}")
        gemini_models = []
    elif resp.status_code == 403:
        print(f"\nERROR 403: Permission denied")
        print("Fix: Go to https://aistudio.google.com/app/apikey and create a NEW key")
        print(f"Response: {resp.text[:300]}")
        gemini_models = []
    else:
        print(f"\nERROR {resp.status_code}: {resp.text[:300]}")
        gemini_models = []

except Exception as e:
    print(f"Connection error: {e}")
    gemini_models = []

# -------------------------------------------------------
# STEP 2: Try sending a message with a working model
# -------------------------------------------------------
print()
print("=" * 55)
print("STEP 2: Testing a real chat message...")
print("=" * 55)

payload = {
    "contents": [{"role": "user", "parts": [{"text": "Say hello in one short sentence."}]}],
    "generationConfig": {"maxOutputTokens": 50},
}

worked = False
for model in gemini_models:
    url = f"https://generativelanguage.googleapis.com/v1beta/models/{model}:generateContent?key={api_key}"
    print(f"\nTrying {model}...")
    try:
        resp = httpx.post(url, json=payload, timeout=15)
        if resp.status_code == 200:
            text = resp.json()["candidates"][0]["content"]["parts"][0]["text"]
            print(f"\nSUCCESS! Model: {model}")
            print(f"Gemini says: {text.strip()}")
            print(f"\nAdd this as the first model in llm_router.py: \"{model}\"")
            worked = True
            break
        else:
            print(f"  Failed: HTTP {resp.status_code}")
    except Exception as e:
        print(f"  Error: {e}")

if not worked:
    if not gemini_models:
        print("\nNo models available. Create a fresh key at:")
        print("  https://aistudio.google.com/app/apikey")
    else:
        print("\nKey works for listing but chat calls failed.")
