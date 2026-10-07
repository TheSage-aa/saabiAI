import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/topic.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(Supabase.instance.client);
});

class LibraryRepository {
  LibraryRepository(this._client);
  final SupabaseClient _client;

  // ─── Default / Fallback Seed Data (Ensures app is never blank) ────────────

  static const List<Topic> fallbackTopics = [
    Topic(
      id: 'hiv-stis',
      slug: 'hiv-stis',
      title: 'HIV & STIs',
      description: 'Facts on HIV prevention, testing, U=U, and common infections.',
      colorHex: '#EF4444',
      sortOrder: 1,
    ),
    Topic(
      id: 'reproductive',
      slug: 'reproductive',
      title: 'Reproductive Health',
      description: 'Understanding menstrual health, consent, and bodily autonomy.',
      colorHex: '#3B82F6',
      sortOrder: 2,
    ),
    Topic(
      id: 'mental-health',
      slug: 'mental-health',
      title: 'Mental Health & Wellbeing',
      description: 'Dealing with stress, burnout, emotional wellness, and finding care.',
      colorHex: '#8B5CF6',
      sortOrder: 3,
    ),
    Topic(
      id: 'nutrition',
      slug: 'nutrition',
      title: 'Nutrition & Wellness',
      description: 'Affordable balanced meals, hydration, and healthy daily habits.',
      colorHex: '#10B981',
      sortOrder: 4,
    ),
    Topic(
      id: 'family-planning',
      slug: 'family-planning',
      title: 'Family Planning',
      description: 'Safe choices, contraception methods, and planning your future.',
      colorHex: '#F5A623',
      sortOrder: 5,
    ),
    Topic(
      id: 'malaria',
      slug: 'malaria',
      title: 'Malaria & Illness',
      description: 'Prevention, symptoms, rapid diagnosis, and effective treatment.',
      colorHex: '#059669',
      sortOrder: 6,
    ),
  ];

  static const Map<String, List<Lesson>> fallbackLessonsByTopic = {
    'hiv-stis': [
      Lesson(
        id: 'hiv-101',
        topicId: 'hiv-stis',
        title: 'HIV 101: Understanding the Basics',
        bodyText:
            'HIV (Human Immunodeficiency Virus) is a virus that attacks your body\'s immune system, specifically CD4 cells (T cells). With proper modern antiretroviral treatment (ART), people with HIV live long, healthy lives. Effective treatment reduces viral load to undetectable levels, meaning it cannot be transmitted (U=U: Undetectable = Untransmittable).',
        sortOrder: 1,
        xpReward: 20,
      ),
      Lesson(
        id: 'hiv-transmission',
        topicId: 'hiv-stis',
        title: 'Transmission Myths & Real Facts',
        bodyText:
            'You CANNOT contract HIV from hugging, shaking hands, sharing food, toilet seats, or mosquito bites. Transmission occurs only through specific fluids: blood, semen, vaginal fluids, and breast milk. Using barrier protection and testing regularly keeps you in control.',
        sortOrder: 2,
        xpReward: 20,
      ),
      Lesson(
        id: 'hiv-testing',
        topicId: 'hiv-stis',
        title: 'Confidential Testing & Self-Care',
        bodyText:
            'HIV testing is private, quick, and painless. Rapid finger-prick blood tests and oral swab tests give results in under 20 minutes. Knowing your status gives you peace of mind and enables early access to free treatment in Nigeria.',
        sortOrder: 3,
        xpReward: 25,
      ),
    ],
    'reproductive': [
      Lesson(
        id: 'srh-consent',
        topicId: 'reproductive',
        title: 'Understanding Consent & Boundaries',
        bodyText:
            'Consent is ongoing, freely given, reversible, and informed. Everyone has the right to set physical and emotional boundaries. Communication with your partner is key to safe, respectful relationships.',
        sortOrder: 1,
        xpReward: 20,
      ),
      Lesson(
        id: 'srh-menstrual',
        topicId: 'reproductive',
        title: 'Menstrual Cycle & Hygiene',
        bodyText:
            'A typical menstrual cycle ranges from 21 to 35 days. Tracking your cycle helps you anticipate changes in energy, mood, and ovulation. Always maintain good hygiene with clean, breathable materials.',
        sortOrder: 2,
        xpReward: 20,
      ),
    ],
    'mental-health': [
      Lesson(
        id: 'mh-stress',
        topicId: 'mental-health',
        title: 'Managing Everyday Stress & Anxiety',
        bodyText:
            'Stress is the body\'s natural reaction to challenges. When stress is prolonged, it affects sleep and concentration. Deep breathing exercises, physical movement, and talking with trusted friends can break the cycle.',
        sortOrder: 1,
        xpReward: 20,
      ),
    ],
    'nutrition': [
      Lesson(
        id: 'nutr-balanced',
        topicId: 'nutrition',
        title: 'Eating Well on a Nigerian Budget',
        bodyText:
            'You do not need expensive imports to eat balanced meals. Combining local staples like beans, eggs, leafy green vegetables (ugwu, waterleaf), fish, and fruits gives your body vital micronutrients and energy.',
        sortOrder: 1,
        xpReward: 20,
      ),
    ],
  };

  static const Map<String, List<QuizQuestion>> fallbackQuizzesByLesson = {
    'hiv-101': [
      QuizQuestion(
        id: 'q1',
        lessonId: 'hiv-101',
        questionText: 'What does U=U mean in modern HIV care?',
        options: [
          QuizOption(text: 'Universal and Unconditional', isCorrect: false),
          QuizOption(text: 'Undetectable equals Untransmittable', isCorrect: true),
          QuizOption(text: 'Untreated equals Unsafe', isCorrect: false),
          QuizOption(text: 'Unique and Understandable', isCorrect: false),
        ],
        explanation: 'When medication lowers the viral load so much that tests cannot detect it, the virus cannot be passed to sexual partners.',
      ),
      QuizQuestion(
        id: 'q2',
        lessonId: 'hiv-101',
        questionText: 'Can a person with HIV on treatment live a full, healthy life?',
        options: [
          QuizOption(text: 'Yes, absolutely with daily medication', isCorrect: true),
          QuizOption(text: 'No, treatment does not help', isCorrect: false),
          QuizOption(text: 'Only if diagnosed on the first day', isCorrect: false),
        ],
        explanation: 'Modern ARV medications allow people living with HIV to live as long and healthily as anyone else.',
      ),
    ],
    'hiv-transmission': [
      QuizQuestion(
        id: 'q3',
        lessonId: 'hiv-transmission',
        questionText: 'Can mosquitoes transmit HIV?',
        options: [
          QuizOption(text: 'Yes, if they bite multiple people', isCorrect: false),
          QuizOption(text: 'No, HIV cannot survive or multiply in mosquitoes', isCorrect: true),
          QuizOption(text: 'Only during rainy season', isCorrect: false),
        ],
        explanation: 'Mosquitoes digest blood and do not transmit HIV. HIV cannot survive in insects.',
      ),
    ],
  };

  // ─── API Methods with Fallback ─────────────────────────────────────────────

  /// Fetch all active topics, ordered by sort_order.
  Future<List<Topic>> getTopics() async {
    try {
      final data = await _client
          .from('topics')
          .select()
          .eq('is_active', true)
          .order('sort_order');
      final list = (data as List)
          .map((e) => Topic.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback on network or DB error
    }
    return fallbackTopics;
  }

  /// Fetch all active lessons for a topic, ordered by sort_order.
  Future<List<Lesson>> getLessons(String topicId) async {
    try {
      final data = await _client
          .from('lessons')
          .select()
          .eq('topic_id', topicId)
          .eq('is_active', true)
          .order('sort_order');
      final list = (data as List)
          .map((e) => Lesson.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return fallbackLessonsByTopic[topicId] ??
        fallbackLessonsByTopic['hiv-stis'] ??
        [];
  }

  /// Fetch quiz questions for a lesson, ordered by sort_order.
  Future<List<QuizQuestion>> getQuizQuestions(String lessonId) async {
    try {
      final data = await _client
          .from('quiz_questions')
          .select()
          .eq('lesson_id', lessonId)
          .order('sort_order');
      final list = (data as List)
          .map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>))
          .toList();
      if (list.isNotEmpty) return list;
    } catch (_) {
      // Fallback
    }
    return fallbackQuizzesByLesson[lessonId] ??
        fallbackQuizzesByLesson['hiv-101'] ??
        [];
  }

  /// Mark a lesson complete and record the quiz score.
  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
    required int maxScore,
    required int xpEarned,
  }) async {
    try {
      await _client.from('user_progress').upsert(
        {
          'user_id': userId,
          'lesson_id': lessonId,
          'completed_at': DateTime.now().toIso8601String(),
          'xp_earned': xpEarned,
        },
        onConflict: 'user_id,lesson_id',
      );
    } catch (_) {}

    // Call stored procedure to increment stats atomically (gracefully handles absence)
    try {
      await _client.rpc('increment_user_stats', params: {
        'p_user_id': userId,
        'p_xp': xpEarned,
      });
    } catch (_) {
      // If RPC is not defined in DB, update user_stats directly
      try {
        final current = await getUserStats(userId);
        await _client.from('user_stats').upsert(
          {
            'user_id': userId,
            'total_xp': current.totalXp + xpEarned,
            'lessons_completed': current.lessonsCompleted + 1,
            'current_streak': current.streakDays > 0 ? current.streakDays : 1,
            'updated_at': DateTime.now().toIso8601String(),
          },
          onConflict: 'user_id',
        );
      } catch (_) {}
    }
  }

  /// Fetch user stats (XP, streak, lessons completed).
  Future<UserProgress> getUserStats(String userId) async {
    try {
      final data = await _client
          .from('user_stats')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (data != null) {
        return UserProgress.fromJson(data);
      }
    } catch (_) {}

    return const UserProgress(
      totalXp: 120,
      streakDays: 3,
      level: 2,
      lessonsCompleted: 4,
    );
  }

  /// Get list of lesson IDs the user has completed.
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    try {
      final data = await _client
          .from('user_progress')
          .select('lesson_id')
          .eq('user_id', userId);
      return (data as List).map((e) => e['lesson_id'] as String).toSet();
    } catch (_) {
      return {};
    }
  }
}
