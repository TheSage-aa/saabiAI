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
      GoRoute(path: '/onboarding/topics', builder: (_, __) => const TopicSelectionScreen()),
      GoRoute(path: '/onboarding/goals', builder: (_, __) => const GoalSettingScreen()),

      // ── Main app with 5-tab bottom nav ────────────────────────────────────
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

// ─── Splash / Welcome Screen with official Saabi logo ────────────────────────
class _WelcomeScreen extends StatelessWidget {
  const _WelcomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.surface,
      body: SafeArea(
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
      ),
    );
  }
}

// ─── 5-tab shell matching Figma ──────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  const _AppShell({required this.child});
  final Widget child;

  int _tabIndex(BuildContext context) {
    final loc = GoRouterState.of(context).matchedLocation;
    if (loc.startsWith('/learn')) return 1;
    if (loc.startsWith('/practice')) return 2;
    if (loc.startsWith('/progress')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0; // home
  }

  @override
  Widget build(BuildContext context) {
    final idx = _tabIndex(context);
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: idx,
        onTap: (i) {
          switch (i) {
            case 0:
              context.go('/home');
              break;
            case 1:
              context.go('/learn');
              break;
            case 2:
              context.go('/practice');
              break;
            case 3:
              context.go('/progress');
              break;
            case 4:
              context.go('/profile');
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_filled),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'Learn',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Practice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_rounded),
            activeIcon: Icon(Icons.trending_up_rounded),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

// ─── Progress Placeholder (Leaderboard / Quizzes) ─────────────────────────────
class _ProgressPlaceholder extends StatelessWidget {
  const _ProgressPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SaabiColors.background,
      appBar: AppBar(
        title: const Text('Progress & Quizzes'),
      ),
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
