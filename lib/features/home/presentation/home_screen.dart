import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/shared_widgets.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/data/library_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final name = auth.displayName;

    return Scaffold(
      backgroundColor: SaabiColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
              horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hey, $name 👋',
                            style: Theme.of(context).textTheme.headlineMedium),
                        Text('Small steps. Big health wins.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: SaabiColors.textSecondary,
                                )),
                      ],
                    ),
                  ),
                  // Streak counter pill
                  Consumer(builder: (_, ref, __) {
                    // Future: load from user stats provider
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
                      decoration: BoxDecoration(
                        color: SaabiColors.surface,
                        borderRadius: BorderRadius.circular(SaabiRadius.full),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.06),
                              blurRadius: 8, offset: const Offset(0, 2))
                        ],
                      ),
                      child: const Row(
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 16)),
                          SizedBox(width: 4),
                          Text('3',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: SaabiColors.textPrimary)),
                        ],
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── XP progress card ────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(SaabiSpacing.md),
                decoration: BoxDecoration(
                  color: SaabiColors.surface,
                  borderRadius: BorderRadius.circular(SaabiRadius.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('YOUR HEALTH JOURNEY',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                )),
                        Text('120 / 200 XP',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SaabiColors.textSecondary,
                                )),
                      ],
                    ),
                    const SizedBox(height: SaabiSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(SaabiRadius.full),
                      child: LinearProgressIndicator(
                        value: 120 / 200,
                        minHeight: 8,
                        backgroundColor: SaabiColors.background,
                        valueColor: const AlwaysStoppedAnimation(SaabiColors.primary),
                      ),
                    ),
                    const SizedBox(height: SaabiSpacing.xs),
                    Text('Level 2 Explorer',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                  ],
                ),
              ),
              const SizedBox(height: SaabiSpacing.lg),

              // ── Topic icon row ────────────────────────────────────────────
              SizedBox(
                height: 90,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: const [
                    _TopicIcon(topicId: 'hiv-stis', emoji: '🎗️', label: 'HIV & STIs', bg: SaabiColors.topicHiv),
                    _TopicIcon(topicId: 'reproductive', emoji: '🌸', label: 'Reproductive', bg: SaabiColors.topicReproductive),
                    _TopicIcon(topicId: 'mental-health', emoji: '🧠', label: 'Mental Health', bg: SaabiColors.topicMentalHealth),
                    _TopicIcon(topicId: 'nutrition', emoji: '🌴', label: 'Nutrition', bg: SaabiColors.topicNutrition),
                  ],
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── Continue Learning ─────────────────────────────────────────
              Text('Continue Learning',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: SaabiSpacing.md),
              GestureDetector(
                onTap: () => context.go('/learn'),
                child: Container(
                  padding: const EdgeInsets.all(SaabiSpacing.lg),
                  decoration: BoxDecoration(
                    color: SaabiColors.primaryLight,
                    borderRadius: BorderRadius.circular(SaabiRadius.xl),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('HIV 101',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.8),
                                    )),
                            const SizedBox(height: 4),
                            Text('What you should know',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    )),
                          ],
                        ),
                      ),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_forward_ios,
                            color: Colors.white, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // ── Today's Goal ─────────────────────────────────────────────
              Text("Today's Goal", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: SaabiSpacing.md),
              Container(
                padding: const EdgeInsets.all(SaabiSpacing.md),
                decoration: BoxDecoration(
                  color: SaabiColors.surface,
                  borderRadius: BorderRadius.circular(SaabiRadius.xl),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: SaabiColors.orangeLight,
                        borderRadius: BorderRadius.circular(SaabiRadius.md),
                      ),
                      child: const Center(child: Text('🔥', style: TextStyle(fontSize: 22))),
                    ),
                    const SizedBox(width: SaabiSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Complete 1 lesson',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )),
                          Text('Keep the streak alive!',
                              style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        color: SaabiColors.textHint, size: 16),
                  ],
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopicIcon extends StatelessWidget {
  const _TopicIcon({
    required this.emoji,
    required this.label,
    required this.bg,
    required this.topicId,
  });

  final String emoji;
  final String label;
  final Color bg;
  final String topicId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: SaabiSpacing.lg),
      child: GestureDetector(
        onTap: () => context.go('/learn/$topicId'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 26))),
            ),
            const SizedBox(height: SaabiSpacing.sm),
            Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
