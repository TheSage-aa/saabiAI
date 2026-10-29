-- =============================================================================
-- Saabi App — Database Seed Data & Functions
-- Run this in Supabase SQL Editor to populate topics, lessons, quizzes & clinics
-- =============================================================================

-- 1. Create or replace the increment_user_stats function
create or replace function public.increment_user_stats(
  p_user_id text,
  p_xp integer
)
returns void
language plpgsql
security definer
as $$
begin
  insert into public.user_stats (user_id, total_xp, lessons_completed, current_streak, last_active_date)
  values (p_user_id, p_xp, 1, 1, current_date)
  on conflict (user_id) do update set
    total_xp = public.user_stats.total_xp + p_xp,
    lessons_completed = public.user_stats.lessons_completed + 1,
    current_streak = case
      when public.user_stats.last_active_date = current_date then public.user_stats.current_streak
      when public.user_stats.last_active_date = current_date - interval '1 day' then public.user_stats.current_streak + 1
      else 1
    end,
    last_active_date = current_date,
    updated_at = now();
end;
$$;

-- 2. Populate Topics
insert into public.topics (id, slug, title, description, icon_name, color_hex, sort_order, is_active) values
  ('b0000001-0000-0000-0000-000000000001', 'hiv-stis', 'HIV & STIs', 'Facts on HIV prevention, testing, U=U, and common infections.', 'health_and_safety', '#EF4444', 1, true),
  ('b0000001-0000-0000-0000-000000000002', 'reproductive', 'Reproductive Health', 'Understanding menstrual health, consent, and bodily autonomy.', 'favorite_border', '#3B82F6', 2, true),
  ('b0000001-0000-0000-0000-000000000003', 'mental-health', 'Mental Health & Wellbeing', 'Dealing with stress, burnout, emotional wellness, and finding care.', 'self_improvement', '#8B5CF6', 3, true),
  ('b0000001-0000-0000-0000-000000000004', 'nutrition', 'Nutrition & Wellness', 'Affordable balanced meals, hydration, and healthy daily habits.', 'restaurant', '#10B981', 4, true),
  ('b0000001-0000-0000-0000-000000000005', 'family-planning', 'Family Planning', 'Safe choices, contraception methods, and planning your future.', 'family_restroom', '#F5A623', 5, true),
  ('b0000001-0000-0000-0000-000000000006', 'malaria', 'Malaria & Illness', 'Prevention, symptoms, rapid diagnosis, and effective treatment.', 'coronavirus', '#059669', 6, true)
on conflict (slug) do update set
  title = excluded.title,
  description = excluded.description,
  color_hex = excluded.color_hex;

-- 3. Populate Lessons
insert into public.lessons (id, topic_id, title, body_text, sort_order, xp_reward, is_active) values
  (
    'c0000001-0000-0000-0000-000000000001',
    'b0000001-0000-0000-0000-000000000001',
    'HIV 101: Understanding the Basics',
    'HIV (Human Immunodeficiency Virus) is a virus that attacks the body''s immune system, specifically the CD4 cells (T cells). With proper modern antiretroviral treatment (ART), people with HIV live long, healthy lives. Effective treatment reduces viral load to undetectable levels, meaning it cannot be transmitted (U=U: Undetectable = Untransmittable).',
    1,
    20,
    true
  ),
  (
    'c0000001-0000-0000-0000-000000000002',
    'b0000001-0000-0000-0000-000000000001',
    'Transmission Myths & Real Facts',
    'You CANNOT contract HIV from hugging, shaking hands, sharing food, toilet seats, or mosquito bites. Transmission occurs only through specific fluids: blood, semen, vaginal fluids, and breast milk. Using barrier protection and testing regularly keeps you in control.',
    2,
    20,
    true
  ),
  (
    'c0000001-0000-0000-0000-000000000003',
    'b0000001-0000-0000-0000-000000000001',
    'Confidential Testing & Self-Care',
    'HIV testing is private, quick, and painless. Rapid finger-prick blood tests and oral swab tests give results in under 20 minutes. Knowing your status gives you peace of mind and enables early access to free treatment in Nigeria.',
    3,
    25,
    true
  ),
  (
    'c0000001-0000-0000-0000-000000000004',
    'b0000001-0000-0000-0000-000000000002',
    'Understanding Consent & Boundaries',
    'Consent is ongoing, freely given, reversible, and informed. Everyone has the right to set physical and emotional boundaries. Communication with your partner is key to safe, respectful relationships.',
    1,
    20,
    true
  )
on conflict (id) do nothing;

-- 4. Populate Quizzes
insert into public.quiz_questions (id, lesson_id, question_text, options, explanation, sort_order) values
  (
    'd0000001-0000-0000-0000-000000000001',
    'c0000001-0000-0000-0000-000000000001',
    'What does U=U mean in modern HIV care?',
    '[{"text": "Universal and Unconditional", "is_correct": false}, {"text": "Undetectable equals Untransmittable", "is_correct": true}, {"text": "Untreated equals Unsafe", "is_correct": false}, {"text": "Unique and Understandable", "is_correct": false}]'::jsonb,
    'When medication lowers the viral load so much that tests cannot detect it, the virus cannot be passed to sexual partners.',
    1
  ),
  (
    'd0000001-0000-0000-0000-000000000002',
    'c0000001-0000-0000-0000-000000000001',
    'Can a person with HIV on treatment live a full, healthy life?',
    '[{"text": "Yes, absolutely with daily medication", "is_correct": true}, {"text": "No, treatment does not help", "is_correct": false}, {"text": "Only if diagnosed on the first day", "is_correct": false}]'::jsonb,
    'Modern ARV medications allow people living with HIV to live as long and healthily as anyone else.',
    2
  ),
  (
    'd0000001-0000-0000-0000-000000000003',
    'c0000001-0000-0000-0000-000000000002',
    'Can mosquitoes transmit HIV?',
    '[{"text": "Yes, if they bite multiple people", "is_correct": false}, {"text": "No, HIV cannot survive or multiply in mosquitoes", "is_correct": true}, {"text": "Only during rainy season", "is_correct": false}]'::jsonb,
    'Mosquitoes digest blood and do not transmit HIV. HIV cannot survive in insects.',
    1
  )
on conflict (id) do nothing;

-- 5. Populate Clinics
insert into public.clinics (id, name, type, state, lga, address, phone, services, is_confidential, cost_description, opening_hours, is_active) values
  (
    'e0000001-0000-0000-0000-000000000001',
    'NACA National AIDS & STIs Helpline',
    'Toll-free Hotline',
    'Nationwide',
    'Abuja Municipal',
    'Plot 823, Ralph Shodehinde Street, CBD, Abuja',
    '6222',
    array['Confidential Counseling', 'Testing Referral', 'Treatment Info', 'Youth Guidance'],
    true,
    '100% Free Toll-Free Call',
    'Mon - Sun: 24/7',
    true
  ),
  (
    'e0000001-0000-0000-0000-000000000002',
    'Action Health Incorporated (AHI) Youth Hub',
    'Youth Friendly Clinic',
    'Lagos',
    'Lagos Mainland',
    '17/19 Commercial Avenue, Sabo, Yaba, Lagos',
    '+234 1 774 1676',
    array['HIV Testing & Counseling', 'STI Screening & Treatment', 'Contraceptive Counseling', 'Peer Support'],
    true,
    'Free for adolescents & youth',
    'Mon - Fri: 8:30 AM - 4:30 PM',
    true
  ),
  (
    'e0000001-0000-0000-0000-000000000003',
    'Planned Parenthood Federation (PPFN) Clinic',
    'Community Health Centre',
    'Lagos',
    'Surulere',
    '228 Ijesha Road, Itire, Surulere, Lagos',
    '+234 803 300 1234',
    array['Reproductive Health Care', 'HIV Screening', 'Family Planning', 'STI Treatment'],
    true,
    'Subsidised / Low-cost',
    'Mon - Fri: 8:00 AM - 5:00 PM',
    true
  ),
  (
    'e0000001-0000-0000-0000-000000000004',
    'Society for Family Health (SFH) Youth Clinic',
    'Youth Clinic & Wellness',
    'Abuja',
    'Abuja Municipal',
    'Justice Sowemimo Street, Asokoro, Abuja',
    '+234 9 461 8820',
    array['HIV Self-Testing Kits', 'PrEP Consultation', 'Sexual Health Education', 'Mental Wellness'],
    true,
    'Free consultations',
    'Mon - Sat: 9:00 AM - 5:00 PM',
    true
  ),
  (
    'e0000001-0000-0000-0000-000000000005',
    'LASACA Wellness & Testing Centre',
    'State Agency Health Post',
    'Lagos',
    'Ikeja',
    'Lagos State Secretariat Complex, Alausa, Ikeja, Lagos',
    '+234 802 319 8888',
    array['Rapid HIV Testing', 'Antiretroviral Linkage', 'Counseling', 'Free Condoms'],
    true,
    'Completely Free',
    'Mon - Fri: 8:00 AM - 4:00 PM',
    true
  )
on conflict (id) do nothing;
