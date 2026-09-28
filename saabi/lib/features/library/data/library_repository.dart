import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/topic.dart';
import '../../../core/storage/user_id_service.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository(Supabase.instance.client);
});

class LibraryRepository {
  LibraryRepository(this._client);
  final SupabaseClient _client;

  /// Fetch all active topics, ordered by sort_order.
  Future<List<Topic>> getTopics() async {
    final data = await _client
        .from('topics')
        .select()
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch all active lessons for a topic, ordered by sort_order.
  Future<List<Lesson>> getLessons(String topicId) async {
    final data = await _client
        .from('lessons')
        .select()
        .eq('topic_id', topicId)
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => Lesson.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Fetch quiz questions for a lesson, ordered by sort_order.
  Future<List<QuizQuestion>> getQuizQuestions(String lessonId) async {
    final data = await _client
        .from('quiz_questions')
        .select()
        .eq('lesson_id', lessonId)
        .order('sort_order');
    return (data as List).map((e) => QuizQuestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Mark a lesson complete and record the quiz score.
  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required int score,
    required int maxScore,
    required int xpEarned,
  }) async {
    await _client.from('user_progress').upsert(
      {
        'user_id': userId,
        'lesson_id': lessonId,
        'quiz_score': score,
        'quiz_max_score': maxScore,
        'is_completed': true,
        'completed_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,lesson_id',
    );

    // Call stored procedure to increment stats atomically
    await _client.rpc('increment_user_stats', params: {
      'p_user_id': userId,
      'p_xp': xpEarned,
    });
  }

  /// Fetch user stats (XP, streak, lessons completed).
  Future<UserProgress> getUserStats(String userId) async {
    final data = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    if (data == null) return const UserProgress.empty();
    return UserProgress.fromJson(data);
  }

  /// Get list of lesson IDs the user has completed.
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    final data = await _client
        .from('user_progress')
        .select('lesson_id')
        .eq('user_id', userId)
        .eq('is_completed', true);
    return (data as List).map((e) => e['lesson_id'] as String).toSet();
  }
}
