import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_progress_service.dart';

class LessonCompleteScreen extends ConsumerWidget {
  const LessonCompleteScreen({super.key, required this.topicId, required this.lessonId});
  final String topicId;
  final String lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

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
                const Text('🔥', style: TextStyle(fontSize: 64)),
                const SizedBox(height: SaabiSpacing.md),
                Text(
                  '${progress.currentStreak}-day streak!',
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: SaabiColors.goldLight,
                    borderRadius: BorderRadius.circular(SaabiRadius.full),
                  ),
                  child: Text(
                    '+20 XP earned · Level ${progress.level}',
                    style: const TextStyle(
                      color: Color(0xFFB45309),
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/learn/$topicId'),
                    child: const Text('Back to Topic'),
                  ),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => context.go('/learn'),
                    child: const Text('All Topics'),
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
