/// App-wide configuration loaded from build-time dart-defines.
///
/// Inject at build time:
///   flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co \
///               --dart-define=SUPABASE_ANON_KEY=eyJ... \
///               --dart-define=SAABI_AI_URL=https://your-tunnel.trycloudflare.com
///
/// In Cloudflare Pages / GitHub Actions, add these as environment variables.
class AppConfig {
  AppConfig._();

  /// Supabase project URL — required, no default.
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Supabase anon/public key — required, no default.
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Saabi AI backend base URL.
  /// Defaults to localhost for local dev. Override via dart-define in CI.
  static const saabiAiUrl = String.fromEnvironment(
    'SAABI_AI_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// App environment label — used for logging/debugging only.
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'development',
  );

  static bool get isProduction => environment == 'production';
}
