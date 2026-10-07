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
    final w = MediaQuery.of(context).size.width;
    final crossAxisCount = w >= 1100 ? 4 : (w >= 700 ? 3 : 2);

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        title: const Text('Learn & Explore'),
        backgroundColor: SaabiColors.background,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1080),
          child: topicsAsync.when(
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
                    padding: const EdgeInsets.all(SaabiSpacing.lg),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: SaabiSpacing.md,
                      mainAxisSpacing: SaabiSpacing.md,
                      childAspectRatio: w >= 700 ? 1.1 : 0.95,
                    ),
                    itemCount: topics.length,
                    itemBuilder: (_, i) => _TopicCard(topic: topics[i]),
                  ),
          ),
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
      borderRadius: BorderRadius.circular(SaabiRadius.xl),
      child: Container(
        decoration: BoxDecoration(
          color: SaabiColors.surface,
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          border: Border.all(color: _cardColor.withOpacity(0.25), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        padding: const EdgeInsets.all(SaabiSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _cardColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(SaabiRadius.md),
              ),
              child: Icon(Icons.menu_book_rounded, color: _cardColor, size: 26),
            ),
            const Spacer(),
            Text(
              topic.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SaabiColors.textPrimary,
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
            const SizedBox(height: SaabiSpacing.sm),
            Row(
              children: [
                Text(
                  'Start Learning',
                  style: TextStyle(
                    color: _cardColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, color: _cardColor, size: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
