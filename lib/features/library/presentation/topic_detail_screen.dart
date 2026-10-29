import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_progress_service.dart';
import '../data/library_repository.dart';

class TopicDetailScreen extends ConsumerWidget {
  const TopicDetailScreen({super.key, required this.topicId});
  final String topicId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topic = LibraryRepository.topicById(topicId);
    final progress = ref.watch(userProgressProvider);

    if (topic == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Not found')),
        body: const Center(child: Text("We couldn't find that topic.")),
      );
    }

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: Text(topic.title),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 820),
          child: ListView(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.sm),
            children: [
              Text(topic.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SaabiColors.textSecondary,
                      )),
              const SizedBox(height: SaabiSpacing.lg),
              ...topic.lessons.map((lesson) {
                final done = progress.isLessonCompleted(lesson.id);
                return Padding(
                  padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                  child: InkWell(
                    onTap: () => context.go('/learn/$topicId/lesson/${lesson.id}'),
                    borderRadius: BorderRadius.circular(SaabiRadius.lg),
                    child: Container(
                      padding: const EdgeInsets.all(SaabiSpacing.md),
                      decoration: BoxDecoration(
                        color: SaabiColors.surface,
                        borderRadius: BorderRadius.circular(SaabiRadius.lg),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: done ? SaabiColors.greenLight : topic.color,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              done ? Icons.check_rounded : Icons.menu_book_rounded,
                              size: 18,
                              color: done ? SaabiColors.green : SaabiColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: SaabiSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(lesson.title,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall
                                        ?.copyWith(fontWeight: FontWeight.w700)),
                                Text('${lesson.estMinutes} min read',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: SaabiColors.textHint,
                                        )),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: SaabiColors.textHint),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
