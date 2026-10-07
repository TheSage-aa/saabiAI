import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/data/auth_repository.dart';
import '../../library/data/library_repository.dart';
import '../../library/domain/topic.dart';

final _userStatsProvider = FutureProvider<UserProgress>((ref) {
  return ref.watch(libraryRepositoryProvider).getUserStats('device-user');
});

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('App Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ListTile(
              leading: Icon(Icons.notifications_active_outlined),
              title: Text('Daily Reminder'),
              subtitle: Text('Notifications at 8:00 PM'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.lock_outline),
              title: Text('Privacy & Security'),
              subtitle: Text('Anonymous health mode active'),
              contentPadding: EdgeInsets.zero,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('About Saabi'),
              subtitle: const Text('Version 1.0 · by LUMA Nigeria'),
              contentPadding: EdgeInsets.zero,
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSavedResources(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SaabiRadius.xl)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(SaabiSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saved Resources',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: SaabiSpacing.md),
            ListTile(
              leading: const Icon(Icons.bookmark, color: SaabiColors.primary),
              title: const Text('U=U: What You Need to Know'),
              subtitle: const Text('HIV Basics • 3 min read'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/learn/hiv-stis');
              },
            ),
            ListTile(
              leading: const Icon(Icons.bookmark, color: SaabiColors.primary),
              title: const Text('Youth Friendly Health Clinics in Nigeria'),
              subtitle: const Text('Directory • Free & confidential'),
              onTap: () {
                Navigator.pop(ctx);
                context.go('/profile/clinics');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authRepositoryProvider);
    final userName = auth.displayName;
    final statsAsync = ref.watch(_userStatsProvider);

    final stats = statsAsync.value ??
        const UserProgress(
          totalXp: 120,
          streakDays: 3,
          level: 2,
          lessonsCompleted: 4,
        );

    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        backgroundColor: SaabiColors.background,
        elevation: 0,
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: SaabiColors.textPrimary,
              ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: SaabiColors.textPrimary),
            onPressed: () => _showSettingsDialog(context),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User name & level
                Text(
                  userName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: SaabiColors.textPrimary,
                      ),
                ),
                const SizedBox(height: SaabiSpacing.xs),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Health Explorer',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: SaabiColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(width: SaabiSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SaabiSpacing.sm, vertical: 2),
                      decoration: BoxDecoration(
                        color: SaabiColors.green,
                        borderRadius: BorderRadius.circular(SaabiRadius.full),
                      ),
                      child: Text(
                        'Level ${stats.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SaabiSpacing.lg),

                // ── Next Level Progress Card ──
                Container(
                  padding: const EdgeInsets.all(SaabiSpacing.lg),
                  decoration: BoxDecoration(
                    color: SaabiColors.surface,
                    borderRadius: BorderRadius.circular(SaabiRadius.xl),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Next Level Progress',
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: SaabiColors.textPrimary,
                                ),
                          ),
                          Text(
                            '${stats.totalXp} / 200 XP',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: SaabiColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SaabiSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(SaabiRadius.full),
                        child: LinearProgressIndicator(
                          value: (stats.totalXp % 200) / 200,
                          minHeight: 8,
                          backgroundColor: const Color(0xFFE5E7EB),
                          valueColor: const AlwaysStoppedAnimation(SaabiColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SaabiSpacing.md),

                // ── 3 Stat Cards in a Row ──
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        emoji: '🔥',
                        value: '${stats.streakDays}',
                        label: 'Day Streak',
                      ),
                    ),
                    const SizedBox(width: SaabiSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        emoji: '📚',
                        value: '${stats.lessonsCompleted}',
                        label: 'Lessons Done',
                      ),
                    ),
                    const SizedBox(width: SaabiSpacing.sm),
                    Expanded(
                      child: _StatCard(
                        emoji: '⭐',
                        value: '${stats.totalXp}',
                        label: 'Total XP',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SaabiSpacing.lg),

                // ── My Goals Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SaabiSpacing.lg),
                  decoration: BoxDecoration(
                    color: SaabiColors.surface,
                    borderRadius: BorderRadius.circular(SaabiRadius.xl),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: SaabiSpacing.sm),
                          Text(
                            'My Goals',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: SaabiColors.textPrimary,
                                ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => context.go('/onboarding/goals'),
                            child: const Text(
                              'Edit',
                              style: TextStyle(
                                color: SaabiColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SaabiSpacing.sm),
                      Text(
                        'Spend 10 minutes daily learning about sexual and physical health wellbeing.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: SaabiColors.textSecondary,
                              height: 1.4,
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: SaabiSpacing.lg),

                // ── Navigation List Tiles ──
                _ProfileNavTile(
                  icon: Icons.explore_outlined,
                  label: 'My Learning Journey',
                  onTap: () => context.go('/learn'),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                _ProfileNavTile(
                  icon: Icons.bookmark_border_rounded,
                  label: 'Saved Resources',
                  onTap: () => _showSavedResources(context),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                _ProfileNavTile(
                  icon: Icons.local_hospital_outlined,
                  label: 'Find Care & Clinics',
                  onTap: () => context.go('/profile/clinics'),
                ),
                const SizedBox(height: SaabiSpacing.sm),
                _ProfileNavTile(
                  icon: Icons.settings_outlined,
                  label: 'Settings',
                  onTap: () => _showSettingsDialog(context),
                ),
                const SizedBox(height: SaabiSpacing.lg),

                // ── Log Out Button ──
                OutlinedButton(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();
                    if (context.mounted) {
                      context.go('/welcome');
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: SaabiColors.error, width: 1.5),
                    foregroundColor: SaabiColors.error,
                  ),
                  child: const Text('Log Out'),
                ),
                const SizedBox(height: SaabiSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.emoji,
    required this.value,
    required this.label,
  });

  final String emoji;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.sm, vertical: SaabiSpacing.md),
      decoration: BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.circular(SaabiRadius.xl),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: SaabiColors.textPrimary,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 10,
                  color: SaabiColors.textSecondary,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ProfileNavTile extends StatelessWidget {
  const _ProfileNavTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SaabiColors.surface,
        borderRadius: BorderRadius.circular(SaabiRadius.xl),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SaabiRadius.xl),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: SaabiSpacing.lg, vertical: SaabiSpacing.md),
            child: Row(
              children: [
                Icon(icon, color: SaabiColors.primary, size: 22),
                const SizedBox(width: SaabiSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: SaabiColors.textPrimary,
                        ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SaabiColors.textSecondary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
