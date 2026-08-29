import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => SupabaseListingRepository(ref.watch(supabaseProvider)),
);

/// Schlanker, einmaliger `search()`-Aufruf ohne Pagination -- Zwischenloesung
/// fuer Task 3.1 (Kategorie-Feed, "Neu eingestellt"). Task 3.2 ersetzt dies
/// durch `listingFeedProvider` als `AsyncNotifier` mit `loadMore()`/`refresh()`.
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
