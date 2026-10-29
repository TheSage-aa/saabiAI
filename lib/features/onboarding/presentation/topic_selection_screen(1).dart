import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/user_id_service.dart';
import '../../library/data/library_repository.dart';

/// First onboarding step after sign-up: pick the topics you're most
/// interested in. The selection is just used to order the Learn tab for
/// now -- there's no personalization backend wired up for it yet, so this
/// stays simple rather than pretending to do more than it does.
class TopicSelectionScreen extends StatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  State<TopicSelectionScreen> createState() => _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends State<TopicSelectionScreen> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(SaabiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('What matters to you?',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: SaabiSpacing.xs),
                  Text(
                    'Pick a few topics you want to learn about. You can always explore more later.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: SaabiColors.textSecondary),
                  ),
                  const SizedBox(height: SaabiSpacing.xl),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: SaabiSpacing.md,
                      mainAxisSpacing: SaabiSpacing.md,
                      childAspectRatio: 1.3,
                      children: LibraryRepository.topics.map((topic) {
                        final selected = _selected.contains(topic.id);
                        return GestureDetector(
                          onTap: () => setState(() {
                            selected ? _selected.remove(topic.id) : _selected.add(topic.id);
                          }),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.all(SaabiSpacing.md),
                            decoration: BoxDecoration(
                              color: selected ? SaabiColors.primaryLight : SaabiColors.surface,
                              borderRadius: BorderRadius.circular(SaabiRadius.lg),
                              border: Border.all(
                                color: selected ? SaabiColors.primary : const Color(0xFFE5E7EB),
                                width: selected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(topic.emoji, style: const TextStyle(fontSize: 32)),
                                const SizedBox(height: SaabiSpacing.sm),
                                Text(
                                  topic.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: SaabiSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/onboarding/goals'),
                      child: const Text('Continue'),
                    ),
                  ),
                  const SizedBox(height: SaabiSpacing.sm),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/onboarding/goals'),
                      child: const Text('Skip for now'),
                    ),
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

/// Second onboarding step. Defined in this file (rather than its own)
/// because `lib/navigation/app_router.dart` only imports
/// `topic_selection_screen.dart` and references `GoalSettingScreen`
/// directly from it -- no separate import exists for it there, so it has
/// to live here to resolve.
class GoalSettingScreen extends StatefulWidget {
  const GoalSettingScreen({super.key});

  @override
  State<GoalSettingScreen> createState() => _GoalSettingScreenState();
}

class _GoalSettingScreenState extends State<GoalSettingScreen> {
  int _minutesPerDay = 10;
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    await UserIdService.instance.completeOnboarding();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(SaabiSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Set a daily goal',
                      style: Theme.of(context).textTheme.headlineLarge),
                  const SizedBox(height: SaabiSpacing.xs),
                  Text(
                    'A little consistency goes a long way. How much time can you give Saabi each day?',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: SaabiColors.textSecondary),
                  ),
                  const SizedBox(height: SaabiSpacing.xl),
                  Row(
                    children: [5, 10, 15, 20].map((m) {
                      final selected = m == _minutesPerDay;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setState(() => _minutesPerDay = m),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 150),
                              padding: const EdgeInsets.symmetric(vertical: SaabiSpacing.md),
                              decoration: BoxDecoration(
                                color: selected ? SaabiColors.primary : SaabiColors.background,
                                borderRadius: BorderRadius.circular(SaabiRadius.md),
                                border: Border.all(
                                  color: selected ? SaabiColors.primary : const Color(0xFFE5E7EB),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '$m min',
                                  style: TextStyle(
                                    color: selected ? Colors.white : SaabiColors.textPrimary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: SaabiSpacing.xxl),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saving ? null : _finish,
                      child: _saving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text("Let's Go"),
                    ),
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
