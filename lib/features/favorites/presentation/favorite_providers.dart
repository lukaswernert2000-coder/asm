import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => SupabaseFavoriteRepository(ref.watch(supabaseProvider)),
);

/// IDs der eigenen Favoriten, neueste zuerst -- fuer den Favoriten-Screen
/// (Task 5.2).
final favoriteListingIdsProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(favoriteRepositoryProvider).myListingIds(),
);

/// Favoritenstatus eines einzelnen Inserats mit optimistischem Umschalten:
/// `toggle()` setzt den Zustand sofort um, bevor die Netzwerkanfrage
/// zurueckkommt, und setzt ihn bei einem Fehler zurueck (Task 5.2). Gleiches
/// Muster wie `ListingFeedNotifier`.
class FavoriteNotifier extends FamilyAsyncNotifier<bool, String> {
  @override
  Future<bool> build(String arg) {
    return ref.watch(favoriteRepositoryProvider).isFavorited(arg);
  }

  Future<void> toggle() async {
    final current = state.valueOrNull ?? false;
    final repository = ref.read(favoriteRepositoryProvider);
    state = AsyncData(!current);
    try {
      if (current) {
        await repository.remove(arg);
      } else {
        await repository.add(arg);
      }
      ref.invalidate(favoriteListingIdsProvider);
    } on AppException {
      state = AsyncData(current);
    }
  }
}

final AsyncNotifierProviderFamily<FavoriteNotifier, bool, String>
favoriteProvider = AsyncNotifierProvider.family<FavoriteNotifier, bool, String>(
  FavoriteNotifier.new,
);
