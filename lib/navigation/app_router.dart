import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/presentation/auth_screens.dart';
import '../features/onboarding/presentation/topic_selection_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/chat/presentation/chat_screen.dart';
import '../features/library/presentation/library_screen.dart';
import '../features/library/presentation/topic_detail_screen.dart';
import '../features/library/presentation/lesson_screen.dart';
import '../features/library/presentation/quiz_results_screen.dart';
import '../features/library/presentation/lesson_complete_screen.dart';
import '../features/profile/presentation/profile_screen.dart';
import '../features/clinics/presentation/clinics_screen.dart';
import '../features/clinics/presentation/clinic_detail_screen.dart';
import '../core/theme/app_theme.dart';
import '../core/layout/responsive.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateChangesProvider);

  return GoRouter(
    initialLocation: '/welcome',
    redirect: (context, state) {
      final isSignedIn = Supabase.instance.client.auth.currentUser != null;
      final loc = state.matchedLocation;

      // Auth routes
      final isAuthRoute = loc == '/welcome' ||
          loc == '/login' ||
          loc == '/signup' ||
          loc == '/forgot-password' ||
          loc.startsWith('/onboarding');

      if (!isSignedIn && !isAuthRoute) return '/welcome';
      if (isSignedIn && (loc == '/welcome' || loc == '/login' || loc == '/signup')) {
        return '/home';
      }
      return null;
    },
    routes: [
      // ── Auth & Onboarding (no shell) ──────────────────────────────────────
      GoRoute(path: '/welcome', builder: (_, __) => const _WelcomeScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
      GoRoute(path: '/forgot-password', builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/onboarding/topics', builder: (_, __) => const TopicSelectionScreen()),
      GoRoute(path: '/onboarding/goals', builder: (_, __) => const GoalSettingScreen()),

      // ── Main app with responsive shell ────────────────────────────────────
      ShellRoute(
        builder: (context, state, child) => _AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            pageBuilder: (_, __) => const NoTransitionPage(child: HomeScreen()),
          ),
          GoRoute(
            path: '/learn',
            pageBuilder: (_, __) => const NoTransitionPage(child: LibraryScreen()),
            routes: [
              GoRoute(
                path: ':topicId',
                builder: (_, state) => TopicDetailScreen(
                  topicId: state.pathParameters['topicId']!,
                ),
                routes: [
                  GoRoute(
                    path: 'lesson/:lessonId',
                    builder: (_, state) => LessonScreen(
                      topicId: state.pathParameters['topicId']!,
                      lessonId: state.pathParameters['lessonId']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'complete',
                        builder: (_, state) => QuizResultsScreen(
                          topicId: state.pathParameters['topicId']!,
                          lessonId: state.pathParameters['lessonId']!,
                        ),
                      ),
                      GoRoute(
                        path: 'streak',
                        builder: (_, state) => LessonCompleteScreen(
                          topicId: state.pathParameters['topicId']!,
                          lessonId: state.pathParameters['lessonId']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/practice',
            pageBuilder: (_, __) => const NoTransitionPage(child: ChatScreen()),
          ),
          GoRoute(
            path: '/progress',
            pageBuilder: (_, __) => const NoTransitionPage(child: _ProgressPlaceholder()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (_, __) => const NoTransitionPage(child: ProfileScreen()),
            routes: [
              GoRoute(
                path: 'clinics',
                builder: (_, __) => const ClinicsScreen(),
                routes: [
                  GoRoute(
                    path: ':clinicId',
                    builder: (_, state) => ClinicDetailScreen(
                      clinicId: state.pathParameters['clinicId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

// ─── Nav destinations shared by bottom nav + sidebar ─────────────────────────
class _NavDestination {
  const _NavDestination({
    required this.path,
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final String path;
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

const _navDestinations = [
  _NavDestination(
    path: '/home',
    icon: Icons.home_outlined,
    activeIcon: Icons.home_filled,
    label: 'Home',
  ),
  _NavDestination(
    path: '/learn',
    icon: Icons.menu_book_outlined,
    activeIcon: Icons.menu_book,
    label: 'Learn',
  ),
  _NavDestination(
    path: '/practice',
    icon: Icons.smart_toy_outlined,
    activeIcon: Icons.smart_toy,
    label: 'Practice',
  ),
  _NavDestination(
    path: '/progress',
    icon: Icons.trending_up_rounded,
    activeIcon: Icons.trending_up_rounded,
    label: 'Progress',
  ),
  _NavDestination(
    path: '/profile',
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

// ─── Responsive App Shell ─────────────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/learn')) return 1;
    if (loc.startsWith('/practice')) return 2;
    if (loc.startsWith('/progress')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _onTap(BuildContext context, int i) {
    context.go(_navDestinations[i].path);
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    final useSidebar = context.useSidebar;

    if (useSidebar) {
      return Scaffold(
        backgroundColor: SaabiColors.background,
        body: Row(
          children: [
            // ── Sidebar ───────────────────────────────────────────────────
            _Sidebar(
              currentIndex: idx,
              onTap: (i) => _onTap(context, i),
              isExpanded: context.isDesktop,
            ),
            // ── Content ───────────────────────────────────────────────────
            Expanded(child: child),
          ],
        ),
      );
    }

    // ── Mobile — bottom nav bar ───────────────────────────────────────────
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) => _onTap(context, i),
        items: _navDestinations
            .map((d) => BottomNavigationBarItem(
                  icon: Icon(d.icon),
                  activeIcon: Icon(d.activeIcon),
                  label: d.label,
                ))
            .toList(),
      ),
    );
  }
}

// ─── Sidebar — collapses to rail on tablet, expands on desktop ───────────────
class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.currentIndex,
    required this.onTap,
    required this.isExpanded,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: isExpanded ? 220 : 72,
      decoration: const BoxDecoration(
        color: SaabiColors.surface,
        border: Border(right: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: SaabiSpacing.lg),

            // Logo / brand
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
              child: isExpanded
                  ? Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: SaabiColors.primary,
                            borderRadius: BorderRadius.circular(SaabiRadius.sm),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(SaabiRadius.sm),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: SaabiSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Saabi',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: SaabiColors.primary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            Text(
                              'by LUMA',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: SaabiColors.green),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Center(
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: SaabiColors.primary,
                          borderRadius: BorderRadius.circular(SaabiRadius.sm),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(SaabiRadius.sm),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: SaabiSpacing.xl),

            // Nav items
            ...List.generate(_navDestinations.length, (i) {
              final d = _navDestinations[i];
              final selected = currentIndex == i;
              return _SidebarItem(
                icon: selected ? d.activeIcon : d.icon,
                label: d.label,
                selected: selected,
                isExpanded: isExpanded,
                onTap: () => onTap(i),
              );
            }),

            const Spacer(),

            // Version hint at bottom
            if (isExpanded)
              Padding(
                padding: const EdgeInsets.all(SaabiSpacing.md),
                child: Text(
                  'Saabi v1.0 · by LUMA',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: SaabiColors.textHint),
                ),
              ),
            const SizedBox(height: SaabiSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isExpanded,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final bool selected;
  final bool isExpanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.sm, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SaabiRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? SaabiColors.primary.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(SaabiRadius.md),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isExpanded ? SaabiSpacing.md : SaabiSpacing.sm,
              vertical: SaabiSpacing.md,
            ),
            child: Row(
              mainAxisAlignment: isExpanded
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected
                      ? SaabiColors.primary
                      : SaabiColors.textSecondary,
                ),
                if (isExpanded) ...[
                  const SizedBox(width: SaabiSpacing.md),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: selected
                              ? SaabiColors.primary
                              : SaabiColors.textSecondary,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Splash / Welcome Screen ──────────────────────────────────────────────────
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    final isWide = context.useSidebar;

    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: isWide
          ? Row(
              children: [
                // Left branding panel — shown on tablet/desktop
                Expanded(
                  child: Container(
                    color: SaabiColors.primary,
                    padding: const EdgeInsets.all(SaabiSpacing.xxl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(SaabiRadius.lg),
                          child: Image.asset(
                            'assets/images/logo.png',
                            height: 80,
                            errorBuilder: (_, __, ___) => Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.favorite,
                                  color: Colors.white, size: 40),
                            ),
                          ),
                        ),
                        const SizedBox(height: SaabiSpacing.xl),
                        Text(
                          'Saabi',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: SaabiSpacing.sm),
                        Text(
                          'by LUMA Nigeria',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: SaabiColors.green,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: SaabiSpacing.xl),
                        Text(
                          'Real health info.\nBetter choices.\nBrighter futures.',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                height: 1.4,
                              ),
                        ),
                        const SizedBox(height: SaabiSpacing.xxl),
                        Row(
                          children: [
                            _FeaturePill(emoji: '🎯', label: 'Gamified Learning'),
                            const SizedBox(width: SaabiSpacing.sm),
                            _FeaturePill(emoji: '🤖', label: 'AI Health Chat'),
                          ],
                        ),
                        const SizedBox(height: SaabiSpacing.sm),
                        Row(
                          children: [
                            _FeaturePill(emoji: '🏥', label: 'Find Clinics'),
                            const SizedBox(width: SaabiSpacing.sm),
                            _FeaturePill(emoji: '🔥', label: 'Daily Streaks'),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Right — auth actions
                Expanded(
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: SaabiSpacing.xxl, vertical: SaabiSpacing.xl),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Get Started',
                              style: Theme.of(context).textTheme.headlineLarge),
                          const SizedBox(height: SaabiSpacing.xs),
                          Text(
                            'Your health literacy journey starts here.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: SaabiColors.textSecondary),
                          ),
                          const SizedBox(height: SaabiSpacing.xxl),
                          ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.go('/signup'),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Create Free Account'),
                                      SizedBox(width: SaabiSpacing.sm),
                                      Icon(Icons.arrow_forward_rounded, size: 18),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: SaabiSpacing.md),
                                OutlinedButton(
                                  onPressed: () => context.go('/login'),
                                  child: const Text('I already have an account'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : _MobileWelcome(),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: SaabiSpacing.md, vertical: SaabiSpacing.sm),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SaabiRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileWelcome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: SaabiSpacing.xl, vertical: SaabiSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(SaabiRadius.md),
                  child: Image.asset(
                    'assets/images/logo.png',
                    height: 52,
                    errorBuilder: (_, __, ___) => Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: SaabiColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite, color: Colors.white, size: 26),
                    ),
                  ),
                ),
                const SizedBox(width: SaabiSpacing.md),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Saabi',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: SaabiColors.primary,
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    Text(
                      'by LUMA',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: SaabiColors.green,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              'Real health info. Better choices. Brighter futures.',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SaabiColors.textPrimary,
                    height: 1.3,
                  ),
            ),
            const Spacer(flex: 2),
            ElevatedButton(
              onPressed: () => context.go('/signup'),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Get Started'),
                  SizedBox(width: SaabiSpacing.sm),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
            const SizedBox(height: SaabiSpacing.md),
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Already have an account? ',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: SaabiColors.textSecondary,
                      ),
                  children: [
                    WidgetSpan(
                      child: GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: SaabiColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Progress Placeholder ─────────────────────────────────────────────────────
class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(title: const Text('Progress & Quizzes')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(SaabiSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.leaderboard_rounded,
                  size: 64, color: SaabiColors.primary),
              const SizedBox(height: SaabiSpacing.md),
              Text(
                'Leaderboard & Stats',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: SaabiSpacing.sm),
              Text(
                'Complete more daily lessons to earn XP and rank up on the community leaderboard!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: SaabiColors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
