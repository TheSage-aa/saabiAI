import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

final _topicLessonsProvider =
    FutureProvider.family<List<Lesson>, String>((ref, topicId) {
  return ref.watch(libraryRepositoryProvider).getLessons(topicId);
});

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lessonsAsync = ref.watch(_topicLessonsProvider(topicId));

    // Dynamic title based on topicId or fallback
    final title = topicId.contains('hiv')
        ? 'HIV & STIs'
        : topicId.replaceAll('-', ' ').split(' ').map((w) => w.isNotEmpty ? '${w[0].toUpperCase()}${w.substring(1)}' : '').join(' ');

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SaabiColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: SaabiColors.textPrimary,
              ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
            horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Course Hero Banner (matches Figma screen-course-topic.png) ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SaabiSpacing.xl),
              decoration: BoxDecoration(
                color: SaabiColors.primary,
                borderRadius: BorderRadius.circular(SaabiRadius.xl),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Know more. Stay safer.',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: SaabiSpacing.sm),
                  Text(
                    'Get the real facts about HIV, other STIs, and how to protect yourself and others.',
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
                // If lessons are empty from Supabase, display the Figma mockup lessons
                final displayLessons = lessons.isNotEmpty
                    ? lessons
                    : [
                        const Lesson(
                          id: 'hiv-101',
                          topicId: 'hiv-stis',
                          title: 'What is HIV?',
                          bodyText: '',
                          xpReward: 10,
                        ),
                        const Lesson(
                          id: 'hiv-transmission',
                          topicId: 'hiv-stis',
                          title: 'How HIV is Transmitted',
                          bodyText: '',
                          xpReward: 10,
                        ),
                        const Lesson(
                          id: 'prevention-methods',
                          topicId: 'hiv-stis',
                          title: 'Prevention Methods',
                          bodyText: '',
                          xpReward: 10,
                        ),
                        const Lesson(
                          id: 'testing-treatment',
                          topicId: 'hiv-stis',
                          title: 'Testing and Treatment',
                          bodyText: '',
                          xpReward: 10,
                        ),
                        const Lesson(
                          id: 'living-well',
                          topicId: 'hiv-stis',
                          title: 'Living Well with HIV',
                          bodyText: '',
                          xpReward: 10,
                        ),
                      ];

                return Column(
                  children: displayLessons.asMap().entries.map((entry) {
                    final index = entry.key;
                    final lesson = entry.value;
                    // First is completed, second is active, rest are locked for mockup demonstration
                    final isCompleted = index == 0;
                    final isActive = index == 1;
                    final isLocked = index > 1;

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
    return Container(
      decoration: BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.circular(SaabiRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          onTap: isLocked
              ? null
              : () => context.go('/learn/$topicId/lesson/${lesson.id}'),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SaabiSpacing.lg,
              vertical: SaabiSpacing.md,
            ),
            child: Row(
              children: [
                // Status icon circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? SaabiColors.greenLight
                        : isActive
                            ? SaabiColors.primary.withOpacity(0.1)
                            : const Color(0xFFF3F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check_circle_outline_rounded,
                            color: SaabiColors.green, size: 24)
                        : isLocked
                            ? const Icon(Icons.lock_outline_rounded,
                                color: SaabiColors.textHint, size: 20)
                            : Text(
                                '$index',
                                style: const TextStyle(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                  ),
                ),
                const SizedBox(width: SaabiSpacing.md),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isLocked
                                  ? SaabiColors.textSecondary
                                  : SaabiColors.textPrimary,
                            ),
                      ),
                      if (!isLocked) ...[
                        const SizedBox(height: 2),
                        Text(
                          '5 min • ${lesson.xpReward} XP',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: SaabiColors.textHint,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (!isLocked)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: SaabiColors.textSecondary,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
