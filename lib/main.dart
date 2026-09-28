import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  assert(
    AppConfig.supabaseUrl.isNotEmpty,
    'SUPABASE_URL must be set via --dart-define=SUPABASE_URL=...',
  );
  assert(
    AppConfig.supabaseAnonKey.isNotEmpty,
    'SUPABASE_ANON_KEY must be set via --dart-define=SUPABASE_ANON_KEY=...',
  );

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: SaabiApp()));
}

class SaabiApp extends ConsumerWidget {
  const SaabiApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    return MaterialApp.router(
      title: 'Saabi',
      debugShowCheckedModeBanner: false,
      theme: SaabiTheme.light,
      routerConfig: router,
    );
  }
}
