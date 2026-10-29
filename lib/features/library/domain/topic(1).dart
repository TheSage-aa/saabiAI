import 'package:flutter/material.dart';

/// NOTE: `lib/navigation/app_router.dart` and the home/practice screens
/// reference a learning library (topics -> lessons -> a short quiz) that
/// never existed anywhere in the Drive project, which was part of why the
/// Flutter app could not compile. This scaffolding gives every referenced
/// route a real, working screen with a *small* set of genuinely accurate,
/// non-clinical lesson content (general facts already safe under the
/// project brief -- nothing here is triage logic, a red-flag symptom list,
/// or mental-health screening language). The full 50-lesson library the
/// product brief/PRD describes still needs to come from Adebare's vetted
/// content source -- this is enough to make the Learn tab functional end
/// to end, not the final content set.

class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.estMinutes,
    required this.paragraphs,
  });

  final String id;
  final String title;
  final int estMinutes;
  final List<String> paragraphs;
}

class Topic {
  const Topic({
    required this.id,
    required this.title,
    required this.emoji,
    required this.color,
    required this.description,
    required this.lessons,
  });

  final String id;
  final String title;
  final String emoji;
  final Color color;
  final String description;
  final List<Lesson> lessons;
}
