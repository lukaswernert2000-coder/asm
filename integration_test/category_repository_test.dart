import 'package:asm/core/config/app_config.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Laeuft gegen die echte Dev-Datenbank, nicht Teil des normalen `flutter
/// test`-Laufs (und damit auch nicht der CI, die keine Supabase-Credentials
/// hat). Manuell ausfuehren mit:
/// flutter test integration_test/category_repository_test.dart --dart-define-from-file=env/dev.json
void main() {
  test('laedt die 8 Wurzelkategorien aus der Dev-Datenbank', () async {
    AppConfig.assertValid();
    final client = SupabaseClient(
      AppConfig.supabaseUrl,
      AppConfig.supabaseAnonKey,
    );
    final repository = SupabaseCategoryRepository(client);

    final roots = await repository.roots();

    expect(roots, hasLength(8));
    expect(roots.map((c) => c.slug), contains('langwaffen'));
  });
}
