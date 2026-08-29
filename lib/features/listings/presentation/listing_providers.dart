import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => SupabaseListingRepository(ref.watch(supabaseProvider)),
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
