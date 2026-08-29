import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Muss in `main()` per `ProviderScope`-Override gesetzt werden --
/// `SharedPreferencesWithCache.create()` ist async, ein Provider-Default
/// koennte nur die veraltete `SharedPreferences.getInstance()`-API nutzen.
final sharedPreferencesProvider = Provider<SharedPreferencesWithCache>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider muss in main() ueberschrieben werden',
  );
});
