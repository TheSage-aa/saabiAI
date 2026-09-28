import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../data/library_repository.dart';
import '../domain/topic.dart';

final _topicsProvider = FutureProvider<List<Topic>>((ref) {
  return ref.watch(libraryRepositoryProvider).getTopics();
});

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topicsAsync = ref.watch(_topicsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Learn')),
      body: topicsAsync.when(
        loading: () => const SaabiLoadingIndicator(),
        error: (e, _) => SaabiErrorBanner(
          message: 'Could not load topics. Check your connection.',
          onRetry: () => ref.invalidate(_topicsProvider),
        ),
        data: (topics) => topics.isEmpty
            ? const SaabiEmptyState(
                icon: Icons.school_outlined,
                message: 'No topics available yet.\nCheck back soon!',
              )
            : GridView.builder(
                padding: const EdgeInsets.all(SaabiSpacing.md),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: SaabiSpacing.md,
                  mainAxisSpacing: SaabiSpacing.md,
                  childAspectRatio: 0.9,
                ),
                itemCount: topics.length,
                itemBuilder: (_, i) => _TopicCard(topic: topics[i]),
              ),
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic});
  final Topic topic;

  Color get _cardColor {
    if (topic.colorHex == null) return SaabiColors.primary;
    try {
      return Color(int.parse(topic.colorHex!.replaceFirst('#', '0xFF')));
    } catch (_) {
      return SaabiColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.go('/learn/${topic.id}'),
      borderRadius: BorderRadius.circular(SaabiRadius.lg),
      child: Container(
        decoration: BoxDecoration(
          color: _cardColor.withOpacity(0.12),
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          border: Border.all(color: _cardColor.withOpacity(0.2)),
        ),
        padding: const EdgeInsets.all(SaabiSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(SaabiRadius.md),
              ),
              child: Icon(Icons.book_outlined, color: _cardColor, size: 24),
            ),
            const Spacer(),
            Text(
              topic.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _cardColor.withOpacity(0.9),
                    fontWeight: FontWeight.w700,
                  ),
              maxLines: 2,
            ),
            if (topic.description != null) ...[
              const SizedBox(height: SaabiSpacing.xs),
              Text(
                topic.description!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: SaabiColors.textSecondary,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
