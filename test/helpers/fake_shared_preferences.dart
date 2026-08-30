import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/onboarding/presentation/onboarding_providers.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Registriert einen In-Memory-Fake als `SharedPreferencesAsyncPlatform` und
/// gibt eine daraus erzeugte `SharedPreferencesWithCache` zurueck -- fuer
/// jeden Test, der `appRouterProvider` aufbaut (liest `hasSeenOnboardingProvider`
/// darin). Default `true`, weil die meisten Tests nichts mit Onboarding zu tun
/// haben und ihr bisheriges Verhalten (kein Onboarding-Redirect) erwarten.
/// `listingViewMode`/`searchHistory` sind optional (Default `null` = nichts
/// gespeichert, Provider faellt auf `grid` bzw. `[]` zurueck) -- die Keys
/// stehen trotzdem immer in der Allowlist, sonst wuerde ein Schreibversuch
/// in einem Test still verworfen.
Future<SharedPreferencesWithCache> fakeSharedPreferences({
  bool hasSeenOnboarding = true,
  ListingViewMode? listingViewMode,
  List<String>? searchHistory,
}) {
  SharedPreferencesAsyncPlatform
      .instance = InMemorySharedPreferencesAsync.withData({
    if (hasSeenOnboarding) hasSeenOnboardingPrefsKey: true,
    if (listingViewMode != null) listingViewModePrefsKey: listingViewMode.name,
    searchHistoryPrefsKey: ?searchHistory,
  });
  return SharedPreferencesWithCache.create(
    cacheOptions: const SharedPreferencesWithCacheOptions(
      allowList: {
        hasSeenOnboardingPrefsKey,
        listingViewModePrefsKey,
        searchHistoryPrefsKey,
      },
    ),
  );
}
