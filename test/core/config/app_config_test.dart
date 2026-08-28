import 'package:asm/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig', () {
    test('isProd ist false, wenn ENVIRONMENT nicht gesetzt ist', () {
      expect(AppConfig.isProd, isFalse);
    });

    test('assertValid wirft, wenn SUPABASE_URL/ANON_KEY fehlen', () {
      expect(AppConfig.assertValid, throwsStateError);
    });
  });
}
