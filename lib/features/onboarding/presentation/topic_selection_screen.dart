import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/layout/responsive.dart';

/// Daily goal options shown during onboarding
enum DailyGoal {
  casual(minutes: 5, label: 'Casual', emoji: '⚡'),
  regular(minutes: 10, label: 'Regular', emoji: '🔥'),
  committed(minutes: 15, label: 'Committed', emoji: '🏆'),
  intense(minutes: 20, label: 'Intense', emoji: '🧠');

  const DailyGoal({required this.minutes, required this.label, required this.emoji});
  final int minutes;
  final String label;
  final String emoji;
}

// All available topics shown during onboarding
class OnboardingTopic {
  const OnboardingTopic({
    required this.id,
    required this.label,
    required this.emoji,
    required this.bg,
    required this.iconColor,
  });
  final String id;
  final String label;
  final String emoji;
  final Color bg;
  final Color iconColor;
}

const _topics = [
  OnboardingTopic(
    id: 'hiv-stis',
    label: 'HIV & STIs',
    emoji: '🎗️',
    bg: SaabiColors.topicHiv,
    iconColor: SaabiColors.topicHivIcon,
  ),
  OnboardingTopic(
    id: 'reproductive',
    label: 'Reproductive',
    emoji: '🌸',
    bg: SaabiColors.topicReproductive,
    iconColor: SaabiColors.topicReproductiveIcon,
  ),
  OnboardingTopic(
    id: 'mental-health',
    label: 'Mental Health',
    emoji: '🧠',
    bg: SaabiColors.topicMentalHealth,
    iconColor: SaabiColors.topicMentalHealthIcon,
  ),
  OnboardingTopic(
    id: 'nutrition',
    label: 'Nutrition',
    emoji: '🌴',
    bg: SaabiColors.topicNutrition,
    iconColor: SaabiColors.topicNutritionIcon,
  ),
  OnboardingTopic(
    id: 'first-aid',
    label: 'First Aid',
    emoji: '🛡️',
    bg: SaabiColors.topicHiv,
    iconColor: SaabiColors.topicHivIcon,
  ),
  OnboardingTopic(
    id: 'family-planning',
    label: 'Family Planning',
    emoji: '😊',
    bg: SaabiColors.goldLight,
    iconColor: SaabiColors.gold,
  ),
  OnboardingTopic(
    id: 'malaria',
    label: 'Malaria & Illness',
    emoji: '🦟',
    bg: SaabiColors.topicNutrition,
    iconColor: SaabiColors.topicNutritionIcon,
  ),
  OnboardingTopic(
    id: 'hygiene',
    label: 'Hygiene',
    emoji: '🧼',
    bg: SaabiColors.topicMentalHealth,
    iconColor: SaabiColors.topicMentalHealthIcon,
  ),
];

// ─── Step 1: Topic selection ──────────────────────────────────────────────────

class TopicSelectionScreen extends ConsumerStatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  ConsumerState<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends ConsumerState<TopicSelectionScreen> {
  final Set<String> _selected = {};

  Future<void> _continue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('user_selected_topics', _selected.toList());
    if (mounted) {
      context.go('/onboarding/goals');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canContinue = _selected.length >= 2;
    final w = MediaQuery.of(context).size.width;
    final crossAxisCount = w >= 900 ? 4 : (w >= 600 ? 3 : 2);

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SaabiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Dot(active: true),
                      SizedBox(width: SaabiSpacing.sm),
                      _Dot(active: false),
                    ],
                  ),
                  const SizedBox(height: SaabiSpacing.lg),
                  Text('What topics interest you?',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: SaabiSpacing.xs),
                  Text('Pick at least 2 to personalise your journey',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SaabiColors.textSecondary,
                          )),
                  const SizedBox(height: SaabiSpacing.xl),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: SaabiSpacing.md,
                        mainAxisSpacing: SaabiSpacing.md,
                        childAspectRatio: 1.35,
                      ),
                      itemCount: _topics.length,
                      itemBuilder: (_, i) {
                        final t = _topics[i];
                        final selected = _selected.contains(t.id);
                        return GestureDetector(
                          onTap: () => setState(() {
                            if (selected) {
                              _selected.remove(t.id);
                            } else {
                              _selected.add(t.id);
                            }
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: SaabiColors.background,
                              borderRadius: BorderRadius.circular(SaabiRadius.xl),
                              border: Border.all(
                                color: selected ? SaabiColors.primary : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            padding: const EdgeInsets.all(SaabiSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: t.bg,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(t.emoji,
                                            style: const TextStyle(fontSize: 18)),
                                      ),
                                    ),
                                    const Spacer(),
                                    if (selected)
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: const BoxDecoration(
                                          color: SaabiColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.check,
                                            color: Colors.white, size: 14),
                                      ),
                                  ],
                                ),
                                const Spacer(),
                                Text(t.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                        )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: SaabiSpacing.md),
                  ElevatedButton(
                    onPressed: canContinue ? _continue : null,
                    child: const Text('Continue →'),
                  ),
                  const SizedBox(height: SaabiSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: Daily goal setting ───────────────────────────────────────────────

class GoalSettingScreen extends ConsumerStatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  ConsumerState<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends ConsumerState<GoalSettingScreen> {
  DailyGoal _selected = DailyGoal.regular;

  Future<void> _saveAndFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_daily_goal_minutes', _selected.minutes);
    await prefs.setString('user_daily_goal_label', _selected.label);
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      appBar: AppBar(
        backgroundColor: SaabiColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: SaabiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      _Dot(active: false),
                      SizedBox(width: SaabiSpacing.sm),
                      _Dot(active: true),
                    ],
                  ),
                  const SizedBox(height: SaabiSpacing.lg),
                  Text('Set your daily goal',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: SaabiSpacing.xs),
                  Text('How much time can you spend learning each day?',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SaabiColors.textSecondary,
                          )),
                  const SizedBox(height: SaabiSpacing.xl),
                  ...DailyGoal.values.map((g) {
                    final selected = _selected == g;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
                      child: GestureDetector(
                        onTap: () => setState(() => _selected = g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
                          decoration: BoxDecoration(
                            color: SaabiColors.background,
                            borderRadius: BorderRadius.circular(SaabiRadius.xl),
                            border: Border.all(
                              color: selected ? SaabiColors.primary : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? SaabiColors.primary.withOpacity(0.1)
                                      : const Color(0xFFE5E7EB),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                    child: Text(g.emoji,
                                        style: const TextStyle(fontSize: 20))),
                              ),
                              const SizedBox(width: SaabiSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${g.minutes} min/day',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.w700,
                                          )),
                                  Text(g.label,
                                      style: Theme.of(context).textTheme.bodySmall),
                                ],
                              ),
                              const Spacer(),
                              if (selected)
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: const BoxDecoration(
                                      color: SaabiColors.primary,
                                      shape: BoxShape.circle),
                                  child: const Icon(Icons.check,
                                      color: Colors.white, size: 16),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: _saveAndFinish,
                    child: const Text('Continue →'),
                  ),
                  const SizedBox(height: SaabiSpacing.md),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 28 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: active ? SaabiColors.primary : const Color(0xFFE5E7EB),
        borderRadius: BorderRadius.circular(SaabiRadius.full),
      ),
    );
  }
}
