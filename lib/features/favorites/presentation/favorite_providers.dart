import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => SupabaseFavoriteRepository(ref.watch(supabaseProvider)),
);

final FutureProviderFamily<bool, String> isFavoritedProvider =
    FutureProvider.family<bool, String>(
      (ref, listingId) =>
          ref.watch(favoriteRepositoryProvider).isFavorited(listingId),
    );

/// Einfaches Umschalten ohne optimistisches Rollback -- das kommt erst mit
/// Task 5.2. Nimmt ein [WidgetRef] (gleiches Muster wie setListingViewMode).
Future<void> toggleFavorite(
  WidgetRef ref,
  String listingId, {
  required bool currentlyFavorited,
}) async {
  final repository = ref.read(favoriteRepositoryProvider);
  if (currentlyFavorited) {
    await repository.remove(listingId);
  } else {
    await repository.add(listingId);
  }
  ref.invalidate(isFavoritedProvider(listingId));
}
