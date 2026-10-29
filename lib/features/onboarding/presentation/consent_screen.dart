import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/user_id_service.dart';
import '../../../navigation/app_router.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _agreed = false;
  bool _loading = false;

  static const _points = [
    ('💬', 'Saabi gives you health information — not medical advice or diagnosis.'),
    ('🔒', 'We don\'t store your name, phone number, or any personal details.'),
    ('🙅', 'No judgment here — your questions about sex, HIV, or mental health are safe to ask.'),
    ('📵', 'We never share what you ask with anyone.'),
    ('🤝', 'For emergencies, always contact a health worker or call 112.'),
  ];

  Future<void> _handleAgree() async {
    setState(() => _loading = true);
    await UserIdService.instance.completeOnboarding();
    if (mounted) context.go(Routes.chat);
  }

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
              Text('Before you start', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: SaabiSpacing.sm),
              Text(
                'Just a few things to know:',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SaabiColors.textSecondary,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.lg),
              Expanded(
                child: ListView(
                  children: _points.map((p) => _ConsentPoint(emoji: p.$1, text: p.$2)).toList(),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: SaabiColors.primary,
                    onChanged: (v) => setState(() => _agreed = v ?? false),
                  ),
                  const SizedBox(width: SaabiSpacing.sm),
                  Expanded(
                    child: Text(
                      'I understand and want to continue',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SaabiSpacing.md),
              ElevatedButton(
                onPressed: (_agreed && !_loading) ? _handleAgree : null,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text("Let's go!"),
              ),
              const SizedBox(height: SaabiSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsentPoint extends StatelessWidget {
  const _ConsentPoint({required this.emoji, required this.text});
  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SaabiSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: SaabiSpacing.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
