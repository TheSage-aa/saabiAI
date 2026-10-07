import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';

class LessonCompleteScreen extends StatelessWidget {
  const LessonCompleteScreen({super.key, required this.topicId, required this.lessonId});
  final String topicId;
  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Days Mon–Sun: filled up to today for demo (Wed = index 2)
    final today = now.weekday; // 1=Mon ... 7=Sun
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Simulate 3-day streak (Mon, Tue, Wed)
    const streakDays = 3;

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 580),
            child: Padding(
              padding: const EdgeInsets.all(SaabiSpacing.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Streak headline
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: SaabiSpacing.sm),
                  Text('$streakDays Day Streak!',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                            color: SaabiColors.orange,
                            fontWeight: FontWeight.w800,
                          )),
                ],
              ),
              const SizedBox(height: SaabiSpacing.sm),
              Text("You're building healthier habits. Keep going!",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SaabiColors.textSecondary,
                      ),
                  textAlign: TextAlign.center),
              const SizedBox(height: SaabiSpacing.xl),

              // Weekly day circles
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
                decoration: BoxDecoration(
                  color: SaabiColors.background,
                  borderRadius: BorderRadius.circular(SaabiRadius.xl),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) {
                    final filled = i < streakDays;
                    return Column(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: filled ? SaabiColors.orange : const Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                          ),
                          child: filled
                              ? const Icon(Icons.check, color: Colors.white, size: 18)
                              : null,
                        ),
                        const SizedBox(height: SaabiSpacing.xs),
                        Text(dayLabels[i],
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  fontWeight: i < streakDays ? FontWeight.w700 : FontWeight.w400,
                                )),
                      ],
                    );
                  }),
                ),
              ),
              const SizedBox(height: SaabiSpacing.xl),

              // XP earned card
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
                decoration: BoxDecoration(
                  color: SaabiColors.surface,
                  borderRadius: BorderRadius.circular(SaabiRadius.xl),
                  border: Border.all(color: SaabiColors.goldLight, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(
                        color: SaabiColors.goldLight,
                        borderRadius: BorderRadius.circular(SaabiRadius.full),
                      ),
                      child: const Center(child: Text('⭐', style: TextStyle(fontSize: 18))),
                    ),
                    const SizedBox(width: SaabiSpacing.md),
                    Text('+10 XP Lesson completed!',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            )),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // Continue Learning (green button — matches Figma)
              ElevatedButton(
                onPressed: () => context.go('/learn/$topicId'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SaabiColors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Continue Learning'),
              ),
              const SizedBox(height: SaabiSpacing.md),

              // Back to Home
              TextButton(
                onPressed: () => context.go('/home'),
                child: const Text('Back to Home',
                    style: TextStyle(color: SaabiColors.textSecondary, fontSize: 14)),
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
