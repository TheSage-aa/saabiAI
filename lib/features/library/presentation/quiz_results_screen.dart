import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_progress_service.dart';
import '../data/library_repository.dart';

/// Shown right after a lesson's content. Awards XP for completing the
/// lesson and hands off to [LessonCompleteScreen] for the streak/XP
/// celebration. Kept deliberately light -- this is a comprehension nudge,
/// not a graded clinical assessment.
class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({super.key, required this.topicId, required this.lessonId});
  final String topicId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lesson = LibraryRepository.lessonById(topicId, lessonId);

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(SaabiSpacing.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 56)),
                const SizedBox(height: SaabiSpacing.md),
                Text(
                  'Nice work!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                Text(
                  'You just finished "${lesson?.title ?? 'this lesson'}". '
                  'Keep going -- every lesson adds to your streak and health knowledge.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: SaabiColors.textSecondary),
                ),
                const SizedBox(height: SaabiSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ref
                          .read(userProgressProvider.notifier)
                          .completeLesson(lessonId);
                      if (context.mounted) {
                        context.go('/learn/$topicId/lesson/$lessonId/streak');
                      }
                    },
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
