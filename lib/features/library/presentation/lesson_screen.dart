import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../data/library_repository.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.topicId, required this.lessonId});
  final String topicId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final lesson = LibraryRepository.lessonById(topicId, lessonId);

    if (lesson == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text("We couldn't find that lesson.")),
      );
    }

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        elevation: 0,
        title: Text(lesson.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(SaabiSpacing.lg),
                  children: [
                    for (final p in lesson.paragraphs) ...[
                      Text(
                        p,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                      ),
                      const SizedBox(height: SaabiSpacing.lg),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SaabiSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () =>
                        context.go('/learn/$topicId/lesson/$lessonId/complete'),
                    child: const Text('Mark as Complete'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
