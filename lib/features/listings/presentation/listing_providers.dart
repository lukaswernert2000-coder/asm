import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final listingRepositoryProvider = Provider<ListingRepository>(
  (ref) => SupabaseListingRepository(ref.watch(supabaseProvider)),
);

/// Aktive Inserate eines Verkaeufers — fuer das eigene und fuer fremde
/// Profile (Task 2.5) gleichermassen genutzt.
final FutureProviderFamily<List<Listing>, String>
activeListingsBySellerProvider = FutureProvider.family<List<Listing>, String>(
  (ref, sellerId) => ref
      .watch(listingRepositoryProvider)
      .bySeller(sellerId, status: ListingStatus.active),
);
