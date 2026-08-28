abstract final class AppConfig {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const sentryDsn = String.fromEnvironment('SENTRY_DSN');
  static const environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: 'dev',
  );

  static bool get isProd => environment == 'prod';

  /// Wirft beim Start, wenn eine Pflichtvariable fehlt – besser ein lauter
  /// Absturz beim Entwickeln als ein stiller Fehler beim Nutzer.
  static void assertValid() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'SUPABASE_URL/SUPABASE_ANON_KEY fehlen. '
        'Starte mit: flutter run --dart-define-from-file=env/dev.json',
      );
    }
  }
}
