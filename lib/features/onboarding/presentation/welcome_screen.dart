import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../navigation/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.primary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SaabiSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              // Logo placeholder — replace with actual logo asset
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SaabiRadius.lg),
                ),
                child: const Center(
                  child: Text('S', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: SaabiColors.primary)),
                ),
              ),
              const SizedBox(height: SaabiSpacing.lg),
              Text(
                'Saabi',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.sm),
              Text(
                'Your health, your questions, your way.\nNo judgment. Just answers.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      height: 1.5,
                    ),
              ),
              const Spacer(flex: 2),
              ElevatedButton(
                onPressed: () => context.go(Routes.ageGate),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: SaabiColors.primary,
                ),
                child: const Text("Let's go"),
              ),
              const SizedBox(height: SaabiSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}
