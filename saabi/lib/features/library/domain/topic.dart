class Topic {
  const Topic({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    this.iconName,
    this.colorHex,
    this.sortOrder = 0,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final String? iconName;
  final String? colorHex;
  final int sortOrder;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'] as String,
      slug: (json['slug'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      description: json['description'] as String?,
      iconName: json['icon_name'] as String?,
      colorHex: json['color_hex'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'title': title,
      'description': description,
      'icon_name': iconName,
      'color_hex': colorHex,
      'sort_order': sortOrder,
    };
  }
}

class Lesson {
  const Lesson({
    required this.id,
    required this.topicId,
    required this.title,
    required this.bodyText,
    this.sortOrder = 0,
    this.xpReward = 10,
  });

  final String id;
  final String topicId;
  final String title;
  final String bodyText;
  final int sortOrder;
  final int xpReward;

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'] as String,
      topicId: (json['topic_id'] ?? '') as String,
      title: (json['title'] ?? '') as String,
      bodyText: (json['body_text'] ?? '') as String,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      xpReward: (json['xp_reward'] as num?)?.toInt() ?? 10,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'body_text': bodyText,
      'sort_order': sortOrder,
      'xp_reward': xpReward,
    };
  }
}

class QuizQuestion {
  const QuizQuestion({
    required this.id,
    required this.lessonId,
    required this.questionText,
    required this.options,
    this.explanation,
    this.sortOrder = 0,
  });

  final String id;
  final String lessonId;
  final String questionText;
  final List<QuizOption> options;
  final String? explanation;
  final int sortOrder;

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as String,
      lessonId: (json['lesson_id'] ?? '') as String,
      questionText: (json['question_text'] ?? '') as String,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => QuizOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      explanation: json['explanation'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'question_text': questionText,
      'options': options.map((e) => e.toJson()).toList(),
      'explanation': explanation,
      'sort_order': sortOrder,
    };
  }
}

class QuizOption {
  const QuizOption({
    required this.text,
    required this.isCorrect,
  });

  final String text;
  final bool isCorrect;

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      text: (json['text'] ?? '') as String,
      isCorrect: json['is_correct'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'is_correct': isCorrect,
    };
  }
}

class UserProgress {
  const UserProgress({
    required this.totalXp,
    required this.lessonsCompleted,
    required this.currentStreak,
    required this.longestStreak,
    this.lastActiveDate,
  });

  final int totalXp;
  final int lessonsCompleted;
  final int currentStreak;
  final int longestStreak;
  final DateTime? lastActiveDate;

  const UserProgress.empty()
      : totalXp = 0,
        lessonsCompleted = 0,
        currentStreak = 0,
        longestStreak = 0,
        lastActiveDate = null;

  factory UserProgress.fromJson(Map<String, dynamic> json) {
    return UserProgress(
      totalXp: (json['total_xp'] as num?)?.toInt() ?? 0,
      lessonsCompleted: (json['lessons_completed'] as num?)?.toInt() ?? 0,
      currentStreak: (json['current_streak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longest_streak'] as num?)?.toInt() ?? 0,
      lastActiveDate: json['last_active_date'] != null
          ? DateTime.tryParse(json['last_active_date'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_xp': totalXp,
      'lessons_completed': lessonsCompleted,
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
      'last_active_date': lastActiveDate?.toIso8601String(),
    };
  }
}
