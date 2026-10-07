import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';

class QuizResultsScreen extends ConsumerWidget {
  const QuizResultsScreen({
    super.key,
    required this.topicId,
    required this.lessonId,
    this.score = 4,
    this.totalQuestions = 5,
    this.xpEarned = 20,
  });

  final String topicId;
  final String lessonId;
  final int score;
  final int totalQuestions;
  final int xpEarned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userName = ref.watch(authRepositoryProvider).displayName;
    final percentage = ((score / totalQuestions) * 100).round();

    final breakdownItems = [
      ('Living with HIV comfortably', true),
      ('Difference between HIV & AIDS', true),
      ('STI transmission prevention', true),
      ('Daily medication benefits', false),
      ('Finding trusted medical clinics', true),
    ];

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Quiz Complete!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SaabiColors.textPrimary,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── Circular Score Ring ──
              Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: SaabiColors.green,
                      width: 5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$score/$totalQuestions',
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: SaabiColors.green,
                            ),
                      ),
                      Text(
                        '$percentage% Score',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: SaabiColors.green,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SaabiSpacing.lg),

              Text(
                'Great job, $userName!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: SaabiColors.textPrimary,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.xs),

              // XP Earned pill badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SaabiSpacing.md, vertical: 4),
                decoration: BoxDecoration(
                  color: SaabiColors.goldLight,
                  borderRadius: BorderRadius.circular(SaabiRadius.full),
                  border: Border.all(color: SaabiColors.gold.withOpacity(0.5)),
                ),
                child: Text(
                  '+$xpEarned XP earned',
                  style: const TextStyle(
                    color: SaabiColors.gold,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── Question Breakdown Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SaabiSpacing.lg),
                decoration: BoxDecoration(
                  color: SaabiColors.background,
                  borderRadius: BorderRadius.circular(SaabiRadius.xl),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Question breakdown',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: SaabiColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: SaabiSpacing.md),
                    ...breakdownItems.asMap().entries.map((entry) {
                      final i = entry.key + 1;
                      final text = entry.value.$1;
                      final passed = entry.value.$2;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: SaabiSpacing.sm),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: SaabiSpacing.md,
                              vertical: SaabiSpacing.sm),
                          decoration: BoxDecoration(
                            color: SaabiColors.surface,
                            borderRadius: BorderRadius.circular(SaabiRadius.md),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '$i',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: SaabiColors.textPrimary,
                                ),
                              ),
                              const SizedBox(width: SaabiSpacing.md),
                              Expanded(
                                child: Text(
                                  text,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                              Icon(
                                passed
                                    ? Icons.check_circle_rounded
                                    : Icons.cancel_rounded,
                                color: passed
                                    ? SaabiColors.green
                                    : SaabiColors.error,
                                size: 22,
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: SaabiSpacing.sm),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Allow reviewing answers
                        },
                        child: const Text(
                          'Review Answers',
                          style: TextStyle(
                            color: SaabiColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── Action Buttons ──
              ElevatedButton(
                onPressed: () => context.go('/learn/$topicId/lesson/$lessonId/streak'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SaabiColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue to Next Lesson'),
              ),
              const SizedBox(height: SaabiSpacing.md),
              OutlinedButton(
                onPressed: () => context.go('/learn/$topicId'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: SaabiColors.primary, width: 1.5),
                  foregroundColor: SaabiColors.primary,
                ),
                child: const Text('Back to Course'),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);
}
}
