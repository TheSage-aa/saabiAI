import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../../navigation/app_router.dart';

class AgeGateScreen extends StatelessWidget {
  const AgeGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(SaabiSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick check',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: SaabiSpacing.sm),
              Text(
                'Saabi is designed for people aged 16 and older. Are you 16 or above?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.go(Routes.consent),
                child: const Text('Yes, I am 16 or older'),
              ),
              const SizedBox(height: SaabiSpacing.md),
              OutlinedButton(
                onPressed: () => _showUnderAgeDialog(context),
                child: const Text("I'm under 16"),
              ),
              const SizedBox(height: SaabiSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnderAgeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SaabiRadius.lg),
        ),
        title: const Text('Thanks for being honest'),
        content: const Text(
          'Saabi is currently for people 16 and older. '
          'If you need health information now, ask a trusted adult, '
          'or look for youth-friendly resources in your school or community.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
