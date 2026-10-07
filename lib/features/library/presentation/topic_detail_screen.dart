import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../../core/services/user_progress_service.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

final _topicLessonsProvider =
    FutureProvider.family<List<Lesson>, String>((ref, topicId) {
  return ref.watch(libraryRepositoryProvider).getLessons(topicId);
});

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  // Topic-specific hero banner config (matches Figma screens)
  ({String title, String headline, String subtitle, Color color}) _topicConfig() {
    switch (topicId) {
      case 'reproductive':
        return (
          title: 'Reproductive Health',
          headline: 'Your Body, Your Power.',
          subtitle:
              'Learn about reproductive systems, cycles, contraception, and healthy relationships.',
          color: const Color(0xFFC026D3),
        );
      case 'mental-health':
        return (
          title: 'Mental Health',
          headline: 'Mind Matters.',
          subtitle:
              'Explore strategies for emotional wellbeing, stress management, and building resilience.',
          color: const Color(0xFF7C3AED),
        );
      case 'nutrition':
        return (
          title: 'Nutrition & Wellness',
          headline: 'Fuel Your Health.',
          subtitle:
              'Practical guidance on affordable balanced meals, hydration, and daily vitality.',
          color: const Color(0xFF059669),
        );
      case 'family-planning':
        return (
          title: 'Family Planning',
          headline: 'Plan Your Future.',
          subtitle:
              'Safe choices, modern contraception methods, and informed family planning.',
          color: const Color(0xFFD97706),
        );
      case 'malaria':
        return (
          title: 'Malaria & Illness',
          headline: 'Prevent & Protect.',
          subtitle:
              'Understanding malaria transmission, prevention, rapid testing, and treatment.',
          color: const Color(0xFF0D9488),
        );
      case 'hiv-stis':
      default:
        return (
          title: 'HIV & STIs',
          headline: 'Know more. Stay safer.',
          subtitle:
              'Get the real facts about HIV, other STIs, and how to protect yourself and others.',
          color: SaabiColors.primary,
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(_topicLessonsProvider(topicId));
    final userProgress = ref.watch(userProgressProvider);
    final config = _topicConfig();

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SaabiColors.textPrimary),
          onPressed: () => context.go('/learn'),
        ),
        title: Text(
          config.title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: SaabiColors.textPrimary,
              ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Course Hero Banner (matches Figma) ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SaabiSpacing.xl),
                  decoration: BoxDecoration(
                    color: config.color,
                    borderRadius: BorderRadius.circular(SaabiRadius.xl),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        config.headline,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: SaabiSpacing.sm),
                      Text(
                        config.subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SaabiSpacing.xl),

                // ── Lesson List ──
                lessonsAsync.when(
                  loading: () => const SaabiLoadingIndicator(),
                  error: (e, _) => SaabiErrorBanner(
                    message: 'Could not load lessons.',
                    onRetry: () => ref.invalidate(_topicLessonsProvider(topicId)),
                  ),
                  data: (lessons) {
                    if (lessons.isEmpty) {
                      return const Center(child: Text('No lessons available.'));
                    }

                    return Column(
                      children: lessons.asMap().entries.map((entry) {
                        final index = entry.key;
                        final lesson = entry.value;

                        final isCompleted =
                            userProgress.isLessonCompleted(lesson.id);
                        final prevCompleted = index == 0 ||
                            userProgress
                                .isLessonCompleted(lessons[index - 1].id);

                        final isActive = !isCompleted && prevCompleted;
                        final isLocked = !isCompleted && !prevCompleted;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                          child: _FigmaLessonCard(
                            lesson: lesson,
                            index: index + 1,
                            topicId: topicId,
                            isCompleted: isCompleted,
                            isActive: isActive,
                            isLocked: isLocked,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FigmaLessonCard extends StatelessWidget {
  const _FigmaLessonCard({
    required this.lesson,
    required this.index,
    required this.topicId,
    required this.isCompleted,
    required this.isActive,
    required this.isLocked,
  });

  final Lesson lesson;
  final int index;
  final String topicId;
  final bool isCompleted;
  final bool isActive;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLocked
            ? () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Complete the previous lesson to unlock this one!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            : () => context.go('/learn/$topicId/lesson/${lesson.id}'),
        borderRadius: BorderRadius.circular(SaabiRadius.xl),
        child: Container(
          decoration: BoxDecoration(
            color: SaabiColors.surface,
            borderRadius: BorderRadius.circular(SaabiRadius.xl),
            border: Border.all(
              color: isActive
                  ? SaabiColors.primary.withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
              width: isActive ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(SaabiSpacing.lg),
          child: Row(
            children: [
              // State Indicator (Check / Number / Lock)
              if (isCompleted)
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: SaabiColors.greenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: SaabiColors.green,
                    size: 20,
                  ),
                )
              else if (isActive)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SaabiColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$index',
                      style: const TextStyle(
                        color: SaabiColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_outline_rounded,
                    color: Colors.grey.shade400,
                    size: 18,
                  ),
                ),
              const SizedBox(width: SaabiSpacing.md),

              // Title and Meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isLocked
                                ? SaabiColors.textHint
                                : SaabiColors.textPrimary,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isCompleted
                          ? 'Completed • Review lesson'
                          : (isLocked
                              ? 'Locked'
                              : '5 min • +${lesson.xpReward} XP'),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: isCompleted
                                ? SaabiColors.green
                                : SaabiColors.textSecondary,
                            fontWeight: isCompleted
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                    ),
                  ],
                ),
              ),

              Icon(
                isLocked
                    ? Icons.lock_outline
                    : Icons.chevron_right_rounded,
                color: isLocked ? Colors.grey.shade300 : SaabiColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
