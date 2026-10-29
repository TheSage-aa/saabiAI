import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Full-screen loading indicator — lightweight, no heavy animation libraries.
class SaabiLoadingIndicator extends StatelessWidget {
  const SaabiLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: SaabiColors.primary,
      ),
    );
  }
}

/// Inline empty/error state widget — warm, non-clinical copy.
class SaabiEmptyState extends StatelessWidget {
  const SaabiEmptyState({
    super.key,
    required this.message,
    this.icon,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SaabiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 56, color: SaabiColors.textHint),
              const SizedBox(height: SaabiSpacing.md),
            ],
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: SaabiColors.textSecondary,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: SaabiSpacing.lg),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionLabel!),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Non-blocking inline error banner — shown above content, never crashes.
class SaabiErrorBanner extends StatelessWidget {
  const SaabiErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(SaabiSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: SaabiSpacing.md,
        vertical: SaabiSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: SaabiColors.error.withOpacity(0.08),
        borderRadius: BorderRadius.circular(SaabiRadius.md),
        border: Border.all(color: SaabiColors.error.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: SaabiColors.error, size: 18),
          const SizedBox(width: SaabiSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: SaabiColors.error,
                  ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: SaabiSpacing.sm),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: SaabiColors.error,
                padding: const EdgeInsets.symmetric(horizontal: SaabiSpacing.sm),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Try again'),
            ),
          ],
        ],
      ),
    );
  }
}

/// Typing indicator — 3 animated dots shown while Saabi AI is replying.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  late final List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      3,
      (i) => AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
    );
    _animations = _controllers
        .map((c) => Tween<double>(begin: 0, end: -6).animate(
              CurvedAnimation(parent: c, curve: Curves.easeInOut),
            ))
        .toList();

    // Stagger each dot by 150ms
    for (var i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 150), () {
        if (mounted) _controllers[i].repeat(reverse: true);
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: _animations[i],
          builder: (_, __) => Transform.translate(
            offset: Offset(0, _animations[i].value),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: SaabiColors.textHint,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}
