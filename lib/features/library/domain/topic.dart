import 'package:freezed_annotation/freezed_annotation.dart';

part 'topic.freezed.dart';
part 'topic.g.dart';

@freezed
class Topic with _$Topic {
  const factory Topic({
    required String id,
    required String slug,
    required String title,
    String? description,
    String? iconName,
    String? colorHex,
    @Default(0) int sortOrder,
  }) = _Topic;

  factory Topic.fromJson(Map<String, dynamic> json) => _$TopicFromJson(json);
}

@freezed
class Lesson with _$Lesson {
  const factory Lesson({
    required String id,
    required String topicId,
    required String title,
    required String bodyText,
    @Default(0) int sortOrder,
    @Default(10) int xpReward,
  }) = _Lesson;

  factory Lesson.fromJson(Map<String, dynamic> json) => _$LessonFromJson(json);
}

@freezed
class QuizQuestion with _$QuizQuestion {
  const factory QuizQuestion({
    required String id,
    required String lessonId,
    required String questionText,
    required List<QuizOption> options,
    String? explanation,
    @Default(0) int sortOrder,
  }) = _QuizQuestion;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) =>
      _$QuizQuestionFromJson(json);
}

@freezed
class QuizOption with _$QuizOption {
  const factory QuizOption({
    required String text,
    required bool isCorrect,
  }) = _QuizOption;

  factory QuizOption.fromJson(Map<String, dynamic> json) =>
      _$QuizOptionFromJson(json);
}

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required int totalXp,
    required int lessonsCompleted,
    required int currentStreak,
    required int longestStreak,
    DateTime? lastActiveDate,
  }) = _UserProgress;

  const factory UserProgress.empty() = _UserProgressEmpty;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}
