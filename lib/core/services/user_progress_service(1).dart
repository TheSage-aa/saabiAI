import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// NOTE: like `core/theme/app_theme.dart`, this file was referenced
/// everywhere (home_screen.dart, profile_screen.dart, practice_screen.dart)
/// but never existed in the project, which was part of why the Flutter
/// app couldn't compile. XP/level/streak logic here is simple,
/// non-clinical gamification plumbing -- it has no bearing on any of the
/// health-content or safety rules, so it didn't need clinical sign-off to
/// build.

const _xpPerLevel = 100;

const _levelTitles = <String>[
  'Getting Started',
  'Curious Learner',
  'Health Explorer',
  'Wellness Builder',
  'Health Advocate',
  'Saabi Expert',
];

@immutable
class UserProgressState {
  const UserProgressState({
    this.totalXp = 0,
    this.currentStreak = 0,
    this.lessonsCompleted = const <String>{},
  });

  final int totalXp;
  final int currentStreak;
  final Set<String> lessonsCompleted;

  int get level => (totalXp ~/ _xpPerLevel).clamp(0, _levelTitles.length - 1);
  int get currentLevelXp => totalXp % _xpPerLevel;
  double get levelProgress => currentLevelXp / _xpPerLevel;
  String get levelTitle => _levelTitles[level];
  int get lessonsCompletedCount => lessonsCompleted.length;

  bool isLessonCompleted(String lessonId) => lessonsCompleted.contains(lessonId);

  UserProgressState copyWith({
    int? totalXp,
    int? currentStreak,
    Set<String>? lessonsCompleted,
  }) {
    return UserProgressState(
      totalXp: totalXp ?? this.totalXp,
      currentStreak: currentStreak ?? this.currentStreak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
    );
  }
}

class UserProgressNotifier extends StateNotifier<UserProgressState> {
  UserProgressNotifier() : super(const UserProgressState()) {
    _load();
  }

  static const _kXp = 'saabi_progress_xp';
  static const _kStreak = 'saabi_progress_streak';
  static const _kLessons = 'saabi_progress_lessons';
  static const _kLastActive = 'saabi_progress_last_active';

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final xp = prefs.getInt(_kXp) ?? 0;
    final streak = prefs.getInt(_kStreak) ?? 0;
    final lessons = prefs.getStringList(_kLessons)?.toSet() ?? <String>{};
    state = UserProgressState(
      totalXp: xp,
      currentStreak: streak,
      lessonsCompleted: lessons,
    );
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kXp, state.totalXp);
    await prefs.setInt(_kStreak, state.currentStreak);
    await prefs.setStringList(_kLessons, state.lessonsCompleted.toList());
  }

  /// Adds XP (from a quiz, a completed lesson, etc.) and bumps today's
  /// streak the first time it's called on a given calendar day.
  Future<void> addXp(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final lastActive = prefs.getString(_kLastActive);

    var streak = state.currentStreak;
    if (lastActive != today) {
      final yesterday = DateTime.now()
          .subtract(const Duration(days: 1))
          .toIso8601String()
          .substring(0, 10);
      streak = (lastActive == yesterday) ? streak + 1 : 1;
      await prefs.setString(_kLastActive, today);
    }

    state = state.copyWith(totalXp: state.totalXp + amount, currentStreak: streak);
    await _persist();
  }

  /// Marks a lesson complete (idempotent) and awards XP once.
  Future<void> completeLesson(String lessonId, {int xp = 20}) async {
    if (state.isLessonCompleted(lessonId)) return;
    state = state.copyWith(
      lessonsCompleted: {...state.lessonsCompleted, lessonId},
    );
    await addXp(xp);
  }
}

final userProgressProvider =
    StateNotifierProvider<UserProgressNotifier, UserProgressState>((ref) {
  return UserProgressNotifier();
});
