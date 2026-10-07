import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Represents user health progress, XP, streak, and completed lessons.
class UserProgressState {
  const UserProgressState({
    required this.totalXp,
    required this.currentStreak,
    required this.longestStreak,
    required this.completedLessonIds,
    required this.lastActiveDate,
    required this.lessonsCompletedCount,
  });

  final int totalXp;
  final int currentStreak;
  final int longestStreak;
  final Set<String> completedLessonIds;
  final String lastActiveDate; // YYYY-MM-DD
  final int lessonsCompletedCount;

  int get level => (totalXp ~/ 100) + 1;
  int get currentLevelXp => totalXp % 100;
  int get xpForNextLevel => 100;
  double get levelProgress => (currentLevelXp / 100).clamp(0.0, 1.0);

  String get levelTitle {
    if (level <= 1) return 'Level 1 Starter';
    if (level == 2) return 'Level 2 Explorer';
    if (level == 3) return 'Level 3 Health Champion';
    if (level == 4) return 'Level 4 Wellness Master';
    return 'Level $level Health Hero';
  }

  UserProgressState copyWith({
    int? totalXp,
    int? currentStreak,
    int? longestStreak,
    Set<String>? completedLessonIds,
    String? lastActiveDate,
    int? lessonsCompletedCount,
  }) {
    return UserProgressState(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      completedLessonIds: completedLessonIds ?? this.completedLessonIds,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      lessonsCompletedCount:
          lessonsCompletedCount ?? this.lessonsCompletedCount,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'completedLessonIds': completedLessonIds.toList(),
        'lastActiveDate': lastActiveDate,
        'lessonsCompletedCount': lessonsCompletedCount,
      };

  factory UserProgressState.fromJson(Map<String, dynamic> json) {
    return UserProgressState(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 1,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 1,
      completedLessonIds: (json['completedLessonIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toSet() ??
          {},
      lastActiveDate: (json['lastActiveDate'] as String?) ?? '',
      lessonsCompletedCount:
          (json['lessonsCompletedCount'] as num?)?.toInt() ?? 0,
    );
  }

  static const initial = UserProgressState(
    totalXp: 0,
    currentStreak: 1,
    longestStreak: 1,
    completedLessonIds: {},
    lastActiveDate: '',
    lessonsCompletedCount: 0,
  );
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier() : super(UserProgressState.initial) {
    _init();
  }

  static const _storageKey = 'saabi_user_progress_v2';

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_storageKey);
      UserProgressState loaded = UserProgressState.initial;
      if (raw != null) {
        try {
          loaded = UserProgressState.fromJson(jsonDecode(raw));
        } catch (_) {}
      }

      // Check daily streak based on real calendar dates
      final todayStr = _formatDate(DateTime.now());
      if (loaded.lastActiveDate.isEmpty) {
        // First session ever
        loaded = loaded.copyWith(
          lastActiveDate: todayStr,
          currentStreak: 1,
          longestStreak: 1,
        );
      } else if (loaded.lastActiveDate != todayStr) {
        final last = DateTime.tryParse(loaded.lastActiveDate);
        final today = DateTime.now();
        if (last != null) {
          final diff = DateTime(today.year, today.month, today.day)
              .difference(DateTime(last.year, last.month, last.day))
              .inDays;

          if (diff == 1) {
            // Consecutive day! Increment streak
            final newStreak = loaded.currentStreak + 1;
            loaded = loaded.copyWith(
              currentStreak: newStreak,
              longestStreak: newStreak > loaded.longestStreak
                  ? newStreak
                  : loaded.longestStreak,
              lastActiveDate: todayStr,
              totalXp: loaded.totalXp + 10, // Daily login reward
            );
          } else if (diff > 1) {
            // Streak broken! Missed at least 1 whole day -> resets to 1
            loaded = loaded.copyWith(
              currentStreak: 1,
              lastActiveDate: todayStr,
            );
          }
        } else {
          loaded = loaded.copyWith(lastActiveDate: todayStr);
        }
      }

      state = loaded;
      await _save(loaded);
      _syncToSupabase(loaded);
    } catch (e) {
      debugPrint('[UserProgress] init error: $e');
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  Future<void> _save(UserProgressState s) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_storageKey, jsonEncode(s.toJson()));
    } catch (_) {}
  }

  void _syncToSupabase(UserProgressState s) {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user != null) {
        client.from('user_stats').upsert({
          'user_id': user.id,
          'total_xp': s.totalXp,
          'lessons_completed': s.lessonsCompletedCount,
          'current_streak': s.currentStreak,
          'longest_streak': s.longestStreak,
          'last_active_date': s.lastActiveDate,
          'updated_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (_) {}
  }

  /// Award XP and record lesson completion
  Future<void> completeLesson({
    required String lessonId,
    required int xpEarned,
  }) async {
    final newSet = Set<String>.from(state.completedLessonIds)..add(lessonId);
    final isNew = !state.completedLessonIds.contains(lessonId);

    final updated = state.copyWith(
      totalXp: state.totalXp + xpEarned,
      completedLessonIds: newSet,
      lessonsCompletedCount: isNew
          ? state.lessonsCompletedCount + 1
          : state.lessonsCompletedCount,
      lastActiveDate: _formatDate(DateTime.now()),
    );

    state = updated;
    await _save(updated);
    _syncToSupabase(updated);
  }

  /// Award XP directly (e.g. from quiz)
  Future<void> addXp(int xp) async {
    final updated = state.copyWith(
      totalXp: state.totalXp + xp,
      lastActiveDate: _formatDate(DateTime.now()),
    );
    state = updated;
    await _save(updated);
    _syncToSupabase(updated);
  }

  bool isLessonCompleted(String lessonId) {
    return state.completedLessonIds.contains(lessonId);
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  return UserProgressNotifier();
});
