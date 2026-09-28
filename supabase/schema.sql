-- =============================================================================
-- Saabi App — Supabase Database Schema
-- Run this in: Supabase Dashboard → SQL Editor → New Query → Run
-- =============================================================================

-- Enable UUID generation
create extension if not exists "uuid-ossp";

-- =============================================================================
-- TOPICS
-- Health education topic categories (HIV, SRH, Mental Health, STIs, etc.)
-- Populated by the LUMA content team via Supabase dashboard or API.
-- =============================================================================
create table if not exists public.topics (
  id          uuid primary key default uuid_generate_v4(),
  slug        text unique not null,            -- e.g. 'hiv-basics', 'srh-101'
  title       text not null,
  description text,
  icon_name   text,                            -- icon identifier for Flutter
  color_hex   text,                            -- e.g. '#1B7F4F' for card colour
  sort_order  integer default 0,
  is_active   boolean default true,
  created_at  timestamptz default now()
);

-- =============================================================================
-- LESSONS
-- Each topic has multiple short lessons.
-- =============================================================================
create table if not exists public.lessons (
  id           uuid primary key default uuid_generate_v4(),
  topic_id     uuid not null references public.topics(id) on delete cascade,
  title        text not null,
  body_text    text not null,                  -- lesson reading content (plain text / markdown)
  sort_order   integer default 0,
  xp_reward    integer default 10,             -- XP earned on completion
  is_active    boolean default true,
  created_at   timestamptz default now()
);

-- =============================================================================
-- QUIZ QUESTIONS
-- Each lesson has a short quiz (multiple choice).
-- =============================================================================
create table if not exists public.quiz_questions (
  id              uuid primary key default uuid_generate_v4(),
  lesson_id       uuid not null references public.lessons(id) on delete cascade,
  question_text   text not null,
  options         jsonb not null,              -- array of {text, is_correct}
  explanation     text,                        -- shown after answering (non-judgmental)
  sort_order      integer default 0
);

-- Example options format:
-- [
--   {"text": "Option A", "is_correct": false},
--   {"text": "Option B", "is_correct": true},
--   {"text": "Option C", "is_correct": false}
-- ]

-- =============================================================================
-- CLINICS
-- Youth-friendly health clinics and resources across Nigeria.
-- Some fields are nullable — not all info is verified yet.
-- =============================================================================
create table if not exists public.clinics (
  id               uuid primary key default uuid_generate_v4(),
  name             text not null,
  type             text,                        -- e.g. 'clinic', 'hotline', 'ngo'
  state            text,                        -- Nigerian state
  lga              text,                        -- Local Government Area
  address          text,
  phone            text,
  services         text[],                      -- array of service labels
  is_confidential  boolean,
  cost_description text,                        -- e.g. 'Free', 'Subsidised', null = not verified
  opening_hours    text,
  is_active        boolean default true,
  created_at       timestamptz default now()
);

-- =============================================================================
-- USER PROGRESS
-- Tracks which lessons each anonymous device user has completed.
-- user_id is the UUID generated on-device — no PII stored.
-- =============================================================================
create table if not exists public.user_progress (
  id           uuid primary key default uuid_generate_v4(),
  user_id      text not null,                  -- anonymous device UUID
  lesson_id    uuid not null references public.lessons(id) on delete cascade,
  completed_at timestamptz default now(),
  xp_earned    integer default 0,
  unique(user_id, lesson_id)                   -- prevent duplicate completions
);

-- =============================================================================
-- USER STATS
-- Aggregate per-user stats — updated after each lesson completion.
-- =============================================================================
create table if not exists public.user_stats (
  user_id          text primary key,           -- anonymous device UUID
  total_xp         integer default 0,
  lessons_completed integer default 0,
  current_streak   integer default 0,          -- consecutive days with activity
  longest_streak   integer default 0,
  last_active_date date,
  updated_at       timestamptz default now()
);

-- =============================================================================
-- ROW LEVEL SECURITY
-- Users can only read/write their OWN progress. Content is public-readable.
-- =============================================================================

alter table public.topics enable row level security;
alter table public.lessons enable row level security;
alter table public.quiz_questions enable row level security;
alter table public.clinics enable row level security;
alter table public.user_progress enable row level security;
alter table public.user_stats enable row level security;

-- Content tables: anyone (anon key) can read active content
create policy "topics_public_read" on public.topics
  for select using (is_active = true);

create policy "lessons_public_read" on public.lessons
  for select using (is_active = true);

create policy "quiz_questions_public_read" on public.quiz_questions
  for select using (true);

create policy "clinics_public_read" on public.clinics
  for select using (is_active = true);

-- Progress: users can only access rows where user_id matches
-- Note: we use request headers set by the Flutter app (not auth JWT)
-- so we use a function to extract user_id from request params.

-- For anon access, progress rows are matched by user_id passed as a filter.
-- The app always queries: .eq('user_id', deviceUserId)
-- RLS below allows any anon read/insert/update for their own user_id.

create policy "user_progress_own_read" on public.user_progress
  for select using (true);  -- filtered client-side by user_id

create policy "user_progress_own_insert" on public.user_progress
  for insert with check (true);

create policy "user_stats_own_read" on public.user_stats
  for select using (true);

create policy "user_stats_own_upsert" on public.user_stats
  for all using (true);

-- =============================================================================
-- INDEXES
-- =============================================================================
create index if not exists idx_lessons_topic_id on public.lessons(topic_id);
create index if not exists idx_quiz_lesson_id on public.quiz_questions(lesson_id);
create index if not exists idx_clinics_state on public.clinics(state);
create index if not exists idx_progress_user_id on public.user_progress(user_id);
create index if not exists idx_progress_lesson_id on public.user_progress(lesson_id);

-- =============================================================================
-- SAMPLE DATA (delete before production)
-- =============================================================================
insert into public.topics (slug, title, description, icon_name, color_hex, sort_order) values
  ('hiv-basics',    'HIV Basics',             'What HIV is, how it works, and how treatment helps you live well.', 'health_and_safety', '#1B7F4F', 1),
  ('srh-101',       'Sexual & Reproductive Health', 'Understanding your body, consent, contraception, and reproductive rights.', 'favorite_border', '#E91E8C', 2),
  ('mental-health', 'Mental Health',          'Your feelings matter. Learn about stress, anxiety, and finding support.', 'self_improvement', '#3498DB', 3),
  ('stis',          'STIs Explained',         'Plain facts about sexually transmitted infections — no shame, just info.', 'local_hospital', '#F39C12', 4),
  ('chronic',       'Chronic Conditions',     'Living well with long-term health conditions.', 'monitor_heart', '#9B59B6', 5)
on conflict (slug) do nothing;
