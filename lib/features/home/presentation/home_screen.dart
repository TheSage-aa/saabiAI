import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/layout/responsive.dart';
import '../../auth/data/auth_repository.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final name = auth.displayName;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 800;

    return Scaffold(
      backgroundColor: SaabiColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1040),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? SaabiSpacing.xl : SaabiSpacing.lg,
                vertical: SaabiSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Hey, $name 👋',
                                style: Theme.of(context).textTheme.headlineMedium),
                            const SizedBox(height: 2),
                            Text('Small steps. Big health wins.',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: SaabiColors.textSecondary,
                                    )),
                          ],
                        ),
                      ),
                      // Streak pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
                        decoration: BoxDecoration(
                          color: SaabiColors.surface,
                          borderRadius: BorderRadius.circular(SaabiRadius.full),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            )
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
                      ),
                    ],
                  ),
                  const SizedBox(height: SaabiSpacing.xl),

                  // ── Layout (2-column on desktop/tablet, stacked on mobile) ──
                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column (60%)
                        Expanded(
                          flex: 6,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const _XpProgressCard(),
                              const SizedBox(height: SaabiSpacing.xl),
                              Text('Explore Topics',
                                  style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: SaabiSpacing.md),
                              const _TopicGrid(),
                              const SizedBox(height: SaabiSpacing.xl),
                              Text('Continue Learning',
                                  style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: SaabiSpacing.md),
                              const _ContinueLearningCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: SaabiSpacing.xl),

                        // Right Column (40%)
                        Expanded(
                          flex: 4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Today's Goal",
                                  style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: SaabiSpacing.md),
                              const _TodaysGoalCard(),
                              const SizedBox(height: SaabiSpacing.xl),
                              Text('Quick Actions',
                                  style: Theme.of(context).textTheme.headlineSmall),
                              const SizedBox(height: SaabiSpacing.md),
                              _QuickActionCard(
                                emoji: '🤖',
                                title: 'Ask Saabi AI',
                                subtitle: 'Have a private question? Chat anytime.',
                                onTap: () => context.go('/practice'),
                              ),
                              const SizedBox(height: SaabiSpacing.md),
                              _QuickActionCard(
                                emoji: '🏥',
                                title: 'Find Clinics',
                                subtitle: 'Locate youth-friendly clinics near you.',
                                onTap: () => context.go('/profile/clinics'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _XpProgressCard(),
                        const SizedBox(height: SaabiSpacing.lg),
                        // Topic icon row for mobile
                        SizedBox(
                          height: 90,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: const [
                              _TopicIcon(
                                  topicId: 'hiv-stis',
                                  emoji: '🎗️',
                                  label: 'HIV & STIs',
                                  bg: SaabiColors.topicHiv),
                              _TopicIcon(
                                  topicId: 'reproductive',
                                  emoji: '🌸',
                                  label: 'Reproductive',
                                  bg: SaabiColors.topicReproductive),
                              _TopicIcon(
                                  topicId: 'mental-health',
                                  emoji: '🧠',
                                  label: 'Mental Health',
                                  bg: SaabiColors.topicMentalHealth),
                              _TopicIcon(
                                  topicId: 'nutrition',
                                  emoji: '🌴',
                                  label: 'Nutrition',
                                  bg: SaabiColors.topicNutrition),
                            ],
                          ),
                        ),
                        const SizedBox(height: SaabiSpacing.xl),
                        Text('Continue Learning',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: SaabiSpacing.md),
                        const _ContinueLearningCard(),
                        const SizedBox(height: SaabiSpacing.xl),
                        Text("Today's Goal",
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: SaabiSpacing.md),
                        const _TodaysGoalCard(),
                        const SizedBox(height: SaabiSpacing.xl),
                      ],
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

// ─── Subcomponents ────────────────────────────────────────────────────────────

class _XpProgressCard extends StatelessWidget {
  const _XpProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SaabiSpacing.lg),
      decoration: BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.circular(SaabiRadius.lg),
        border: Border.all(color: const Color(0xFFE5E7EB)),
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
                        fontWeight: FontWeight.w600,
                      )),
            ],
          ),
          const SizedBox(height: SaabiSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(SaabiRadius.full),
            child: const LinearProgressIndicator(
              value: 120 / 200,
              minHeight: 10,
              backgroundColor: SaabiColors.background,
              valueColor: AlwaysStoppedAnimation(SaabiColors.primary),
            ),
          ),
          const SizedBox(height: SaabiSpacing.sm),
          Row(
            children: [
              Text('Level 2 Explorer',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      )),
              const Spacer(),
              Text('80 XP until Level 3',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: SaabiColors.textHint,
                      )),
            ],
          ),
        ],
      ),
    );
  }
}

class _TopicGrid extends StatelessWidget {
  const _TopicGrid();

  @override
  Widget build(BuildContext context) {
    const topics = [
      ('hiv-stis', '🎗️', 'HIV & STIs', SaabiColors.topicHiv),
      ('reproductive', '🌸', 'Reproductive', SaabiColors.topicReproductive),
      ('mental-health', '🧠', 'Mental Health', SaabiColors.topicMentalHealth),
      ('nutrition', '🌴', 'Nutrition', SaabiColors.topicNutrition),
    ];

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: SaabiSpacing.md,
      mainAxisSpacing: SaabiSpacing.md,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.8,
      children: topics.map((t) {
        return InkWell(
          onTap: () => context.go('/learn/${t.$1}'),
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
            decoration: BoxDecoration(
              color: SaabiColors.surface,
              borderRadius: BorderRadius.circular(SaabiRadius.lg),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: t.$4, shape: BoxShape.circle),
                  child: Center(
                      child: Text(t.$2, style: const TextStyle(fontSize: 20))),
                ),
                const SizedBox(width: SaabiSpacing.md),
                Expanded(
                  child: Text(t.$3,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          )),
                ),
                const Icon(Icons.chevron_right, color: SaabiColors.textHint),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
              width: 40,
              height: 40,
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
    );
  }
}

class _TodaysGoalCard extends StatelessWidget {
  const _TodaysGoalCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SaabiSpacing.md),
      decoration: BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.circular(SaabiRadius.xl),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: SaabiColors.orangeLight,
              borderRadius: BorderRadius.circular(SaabiRadius.md),
            ),
            child: const Center(
                child: Text('🔥', style: TextStyle(fontSize: 24))),
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
                Text('Keep your 3-day streak alive!',
                    style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios,
              color: SaabiColors.textHint, size: 16),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            Text(emoji, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: SaabiSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: SaabiColors.textPrimary,
                          )),
                  Text(subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: SaabiColors.textSecondary,
                            fontSize: 12,
                          )),
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
