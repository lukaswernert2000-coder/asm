import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/listings/data/image_service.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => SupabaseListingRepository(ref.watch(supabaseProvider)),
);

final imageServiceProvider = Provider<ImageService>(
  (ref) => ImageService(ref.watch(supabaseProvider)),
);

final manufacturersProvider = FutureProvider<List<String>>(
  (ref) => ref.watch(listingRepositoryProvider).manufacturers(),
);

enum ListingViewMode { grid, list }

const listingViewModePrefsKey = 'listing_view_mode';

/// Grid ist der Default, solange nichts gespeichert ist. Siehe
/// 01-DESIGN-SYSTEM.md Abschnitt 5.4 ("Umschaltbar ueber ein Icon in der
/// AppBar, Auswahl in shared_preferences merken").
final Provider<ListingViewMode> listingViewModeProvider =
    Provider<ListingViewMode>((ref) {
      final raw = ref
          .watch(sharedPreferencesProvider)
          .getString(listingViewModePrefsKey);
      return raw == ListingViewMode.list.name
          ? ListingViewMode.list
          : ListingViewMode.grid;
    });

Future<void> setListingViewMode(WidgetRef ref, ListingViewMode mode) async {
  await ref
      .read(sharedPreferencesProvider)
      .setString(listingViewModePrefsKey, mode.name);
  ref.invalidate(listingViewModeProvider);
}

/// Schlanker, einmaliger `search()`-Aufruf ohne Pagination -- fuer Stellen,
/// die keine Pagination brauchen (z. B. "Neu eingestellt" auf der
/// Startseite). Der paginierte Haupt-Feed nutzt `listingFeedProvider`
/// (`listing_feed_controller.dart`, Task 3.2).
final FutureProviderFamily<
  ({List<ListingSummary> items, int total}),
  ListingFilter
>
categoryFeedProvider =
    FutureProvider.family<
      ({List<ListingSummary> items, int total}),
      ListingFilter
    >(
      (ref, filter) => ref.watch(listingRepositoryProvider).search(filter),
    );

/// Aktive Inserate eines Verkaeufers — fuer das eigene und fuer fremde
/// Profile (Task 2.5) gleichermassen genutzt.
final FutureProviderFamily<List<Listing>, String>
activeListingsBySellerProvider = FutureProvider.family<List<Listing>, String>(
  (ref, sellerId) => ref
      .watch(listingRepositoryProvider)
      .bySeller(sellerId, status: ListingStatus.active),
);

final FutureProviderFamily<Listing, String> listingByIdProvider =
    FutureProvider.family<Listing, String>(
      (ref, id) => ref.watch(listingRepositoryProvider).byId(id),
    );

/// Rohe Storage-Pfade der oeffentlichen Fotos eines Inserats, sortiert
/// (`ListingRepository.imagePaths`, nur `kind=photo`). Aufloesung zur echten
/// URL passiert erst in der Praesentationsschicht via `listingImageUrl()` --
/// exakt das Muster von `Profile.avatarPath` + `avatarUrl()`.
final FutureProviderFamily<List<String>, String> listingImagePathsProvider =
    FutureProvider.family<List<String>, String>(
      (ref, id) => ref.watch(listingRepositoryProvider).imagePaths(id),
    );

/// Fuer die vier Tabs in "Meine Inserate" (Task 4.3) — anders als
/// [activeListingsBySellerProvider] parametrisiert ueber den Status, den der
/// jeweilige Tab braucht.
final FutureProviderFamily<
  List<Listing>,
  ({String sellerId, ListingStatus status})
>
listingsBySellerStatusProvider =
    FutureProvider.family<
      List<Listing>,
      ({String sellerId, ListingStatus status})
    >(
      (ref, args) => ref
          .watch(listingRepositoryProvider)
          .bySeller(args.sellerId, status: args.status),
    );

/// Nach Bearbeiten/Hochschieben/Statuswechsel/Loeschen (Task 4.3) alle vier
/// "Meine Inserate"-Tabs invalidieren, egal von wo die Aenderung ausgeloest
/// wurde -- z. B. verschiebt "Als verkauft markieren" ein Inserat vom
/// Aktiv- in den Verkauft-Tab, und `EditListingScreen` kennt die Tabs gar
/// nicht selbst. Invalidiert auch `listingByIdProvider(listingId)` --
/// Detailseite und Favoriten (Task 5.1/5.2) lesen denselben Cache und
/// bekamen den Statuswechsel bisher erst nach einem Neustart mit (per
/// Live-Test in Task 5.2 gefunden: "Als verkauft markieren" liess den
/// "Verkauft"-Badge auf einem bereits geladenen Favoriten falsch aus).
void refreshSellerListings(
  WidgetRef ref, {
  required String sellerId,
  required String listingId,
}) {
  ref.invalidate(listingByIdProvider(listingId));
  for (final status in ListingStatus.values) {
    if (status == ListingStatus.archived || status == ListingStatus.blocked) {
      continue;
    }
    ref.invalidate(
      listingsBySellerStatusProvider((sellerId: sellerId, status: status)),
    );
  }
}
