import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../domain/topic.dart';
import '../../../core/storage/user_id_service.dart';

part 'library_repository.g.dart';

@riverpod
LibraryRepository libraryRepository(LibraryRepositoryRef ref) {
  return LibraryRepository(Supabase.instance.client);
}

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
    return (data as List).map((e) => Topic.fromJson(e)).toList();
  }

  /// Fetch all active lessons for a topic.
  Future<List<Lesson>> getLessons(String topicId) async {
    final data = await _client
        .from('lessons')
        .select()
        .eq('topic_id', topicId)
        .eq('is_active', true)
        .order('sort_order');
    return (data as List).map((e) => Lesson.fromJson(e)).toList();
  }

  /// Fetch quiz questions for a lesson.
  Future<List<QuizQuestion>> getQuizQuestions(String lessonId) async {
    final data = await _client
        .from('quiz_questions')
        .select()
        .eq('lesson_id', lessonId)
        .order('sort_order');
    return (data as List).map((e) => QuizQuestion.fromJson(e)).toList();
  }

  /// Mark a lesson as complete and award XP.
  Future<void> completeLesson({
    required String userId,
    required String lessonId,
    required int xpReward,
  }) async {
    // Record completion (ignore if already completed — unique constraint)
    await _client.from('user_progress').upsert({
      'user_id': userId,
      'lesson_id': lessonId,
      'xp_earned': xpReward,
    }, onConflict: 'user_id, lesson_id');

    // Update aggregate stats
    await _client.rpc('increment_user_stats', params: {
      'p_user_id': userId,
      'p_xp': xpReward,
    });
  }

  /// Get aggregate stats for this device user.
  Future<UserProgress?> getUserStats(String userId) async {
    final data = await _client
        .from('user_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
    if (data == null) return null;
    return UserProgress.fromJson(data);
  }

  /// Returns set of completed lesson IDs for this user.
  Future<Set<String>> getCompletedLessonIds(String userId) async {
    final data = await _client
        .from('user_progress')
        .select('lesson_id')
        .eq('user_id', userId);
    return (data as List).map((e) => e['lesson_id'] as String).toSet();
  }
}
