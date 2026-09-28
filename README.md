# Saabi App

Gamified health literacy mobile app by LUMA (Luminating Africa).
Teaches young people in Nigeria SRHR, HIV, mental health, STIs, and general wellness through bite-sized, Duolingo-style lessons and an in-app AI health companion.

---

## Tech Stack
- **Flutter** — iOS, Android, Web
- **Supabase** — PostgreSQL database + Supabase Auth (Email/Password & Google OAuth)
- **Saabi AI** — external AI companion service (`POST /chat`)
- **Cloudflare Pages + GitHub Actions** — Free hosting and automated CI/CD

---

## Design System & Theme
Built according to the official Figma designs:
- **Brand Navy Blue (`#1B3A8C`)** — Primary buttons, headers, active navigation
- **Health Green (`#4CAF50`)** — Success indicators, completed lessons, level badges
- **Streak Orange (`#FF9800`)** — Streak counter, daily goal motivation
- **Award Gold (`#F5A623`)** — XP rewards, stars, celebration medals
- **Font:** Nunito (friendly, legible, rounded)

---

## App Structure & Flow
```
lib/
├── core/
│   ├── config/       # AppConfig — dart-define environment variables
│   ├── network/      # SaabiAiClient (Dio) for AI chat calls
│   ├── storage/      # UserIdService — device storage & preferences
│   ├── theme/        # SaabiTheme, SaabiColors, spacing tokens
│   └── widgets/      # Shared UI: LoadingIndicator, ErrorBanner, EmptyState
├── features/
│   ├── auth/         # Supabase Auth: Login & Signup (Email/Password + Google)
│   ├── onboarding/   # Topic selection (pick ≥2) → Daily goal setting (5-20 min)
│   ├── home/         # Home dashboard: streak, level progress, topic circles, daily goal
│   ├── library/      # Course topics, bite-sized lessons, interactive quiz, streak celebration
│   ├── chat/         # "Ask Saabi" AI health companion (disclaimer banner, bubble UI)
│   ├── clinics/      # Confidential clinic finder with state filters
│   └── profile/      # User profile: stats, goals card, learning journey, settings
├── navigation/       # GoRouter with auth guards & 5-tab bottom navigation shell
└── main.dart
supabase/
└── schema.sql        # Full database schema + RPC functions
```

---

## Getting Started

### 1. Set up Supabase
1. Create a free project at [supabase.com](https://supabase.com).
2. Go to **SQL Editor** → paste and run the contents of [`supabase/schema.sql`](supabase/schema.sql).
3. In **Authentication** → **Providers**:
   - Ensure **Email** is enabled.
   - (Optional) Enable **Google** by adding your Google Client ID & Secret from Google Cloud Console.
4. Copy your **Project URL** and **anon public key** from **Project Settings** → **API**.

### 2. Run the App Locally
```bash
# 1. Install dependencies
flutter pub get

# 2. Run code generation (freezed models, Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# 3. Run with your Supabase credentials
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key \
  --dart-define=SAABI_AI_URL=http://localhost:8000
```

### 3. Exposing Local Saabi AI (for testing)
If your Saabi AI backend runs locally on port 8000:
```bash
cloudflared tunnel --url http://localhost:8000
```
Then pass the generated `https://*.trycloudflare.com` URL as `--dart-define=SAABI_AI_URL=...`.

---

## Deployment to Cloudflare Pages

### Option A: Automatic via GitHub (Recommended)
1. Push this project to your GitHub repository.
2. In your [Cloudflare Dashboard](https://dash.cloudflare.com) → **Workers & Pages** → **Create application** → **Pages** → **Connect to Git**.
3. Select your Saabi repository.
4. Set build settings:
   - **Framework preset:** None
   - **Build command:**
     ```bash
     flutter build web --release --dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY --dart-define=SAABI_AI_URL=$SAABI_AI_URL --dart-define=ENVIRONMENT=production
     ```
   - **Build output directory:** `build/web`
5. In **Environment variables**, add:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`
   - `SAABI_AI_URL`
6. Click **Save and Deploy**.

### Option B: Automated GitHub Actions CI
The repository already includes [`.github/workflows/ci.yml`](.github/workflows/ci.yml).
Add `SUPABASE_URL`, `SUPABASE_ANON_KEY`, and `SAABI_AI_URL` to your **GitHub Repo → Settings → Secrets and variables → Actions**.

---

## Non-negotiables
- **No clinical triage in Flutter code:** Health companion is an informational tool only.
- **Status-neutral tone:** Non-judgmental language across all lessons, quizzes, and UI text.
- **Privacy-first:** Only essential profile data stored securely via Supabase.
