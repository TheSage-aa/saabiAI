import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_progress_service.dart';
import '../data/library_repository.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(userProgressProvider);

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: Text('Learn',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SaabiColors.textPrimary,
                )),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.sm),
            children: [
              Text(
                '${progress.lessonsCompletedCount} lessons completed · Level ${progress.level}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SaabiColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.lg),
              ...LibraryRepository.topics.map((topic) => Padding(
                    padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                    child: _TopicCard(
                      topic: topic,
                      completedCount: topic.lessons
                          .where((l) => progress.isLessonCompleted(l.id))
                          .length,
                      onTap: () => context.go('/learn/${topic.id}'),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.completedCount,
    required this.onTap,
  });

  final dynamic topic;
  final int completedCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SaabiRadius.xl),
      child: Container(
        padding: const EdgeInsets.all(SaabiSpacing.lg),
        decoration: BoxDecoration(
          color: SaabiColors.surface,
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: topic.color, shape: BoxShape.circle),
              child: Center(
                child: Text(topic.emoji, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: SaabiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(topic.title as String,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(topic.description as String,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SaabiColors.textSecondary,
                          )),
                  const SizedBox(height: SaabiSpacing.xs),
                  Text(
                    '$completedCount / ${(topic.lessons as List).length} lessons done',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: SaabiColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: SaabiColors.textHint),
          ],
        ),
      ),
    );
  }
}
