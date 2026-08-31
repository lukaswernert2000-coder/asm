import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ListingRepository {
  Future<({List<ListingSummary> items, int total})> search(
    ListingFilter filter, {
    int limit = 24,
    int offset = 0,
  });
  Future<Listing> byId(String id);
  Future<List<Listing>> bySeller(String sellerId, {ListingStatus? status});
  Future<String> create(ListingDraft draft);
  Future<void> update(String id, ListingDraft draft);
  Future<void> setStatus(String id, ListingStatus status);
  Future<void> bump(String id);
  Future<void> delete(String id);
  Future<void> incrementView(String id);
  Future<List<String>> manufacturers();
  Future<void> insertImage(
    String listingId, {
    required String storagePath,
    required ImageKind kind,
    required int sortOrder,
  });
  Future<List<String>> imagePaths(String listingId);
}

/// Ruft eine Postgres-RPC auf und liefert die Zeilen als rohe Maps.
///
/// Eigener Seam statt `_client.rpc()` direkt in [SupabaseListingRepository]
/// aufzurufen: `PostgrestFilterBuilder` implementiert `Future`, was es mit
/// mocktail praktisch unmoeglich macht sauber zu stubben (bekanntes,
/// ungeloestes Problem, siehe supabase/supabase-flutter#714). Tests injizieren
/// hier stattdessen eine einfache Fake-Funktion.
typedef RpcCaller = Future<List<dynamic>> Function(
  String fn,
  Map<String, dynamic> params,
);

class SupabaseListingRepository implements ListingRepository {
  SupabaseListingRepository(this._client, {RpcCaller? rpcCaller})
    : _rpc = rpcCaller ?? _defaultRpcCaller(_client);

  final SupabaseClient _client;
  final RpcCaller _rpc;

  static RpcCaller _defaultRpcCaller(SupabaseClient client) =>
      (fn, params) => client.rpc<List<dynamic>>(fn, params: params);

  @override
  Future<({List<ListingSummary> items, int total})> search(
    ListingFilter filter, {
    int limit = 24,
    int offset = 0,
  }) async {
    try {
      final rows = await _rpc(
        'search_listings',
        {
          'p_query': filter.query,
          'p_category': filter.categorySlug,
          'p_min_price': filter.minPrice,
          'p_max_price': filter.maxPrice,
          'p_conditions': filter.conditions?.map(_conditionToDb).toList(),
          'p_propulsions': filter.propulsions?.map((p) => p.name).toList(),
          'p_min_joule': filter.minJoule,
          'p_max_joule': filter.maxJoule,
          'p_ships': filter.ships,
          'p_lat': filter.lat,
          'p_lng': filter.lng,
          'p_radius_km': filter.radiusKm,
          'p_sort': _sortToDb(filter.sort),
          'p_limit': limit,
          'p_offset': offset,
        },
      );
      final items = rows
          .cast<Map<String, dynamic>>()
          .map(ListingSummary.fromJson)
          .toList();
      final total = rows.isEmpty
          ? 0
          : (rows.first as Map<String, dynamic>)['total_count'] as int;
      return (items: items, total: total);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<Listing> byId(String id) async {
    try {
      final row = await _client.from('listings').select().eq('id', id).single();
      return Listing.fromJson(row);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<List<Listing>> bySeller(
    String sellerId, {
    ListingStatus? status,
  }) async {
    try {
      var query = _client.from('listings').select().eq('seller_id', sellerId);
      if (status != null) {
        query = query.eq('status', status.name);
      }
      final rows = await query.order('created_at', ascending: false);
      return rows.map(Listing.fromJson).toList();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<String> create(ListingDraft draft) async {
    final sellerId = _client.auth.currentUser?.id;
    if (sellerId == null) throw const AuthRequiredException();
    try {
      final row = await _client
          .from('listings')
          .insert({...draft.toJson(), 'seller_id': sellerId})
          .select('id')
          .single();
      return row['id'] as String;
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> update(String id, ListingDraft draft) async {
    try {
      await _client.from('listings').update(draft.toJson()).eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> setStatus(String id, ListingStatus status) async {
    try {
      await _client
          .from('listings')
          .update({'status': status.name})
          .eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> bump(String id) async {
    try {
      await _client
          .from('listings')
          .update({'bumped_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await _client.from('listings').delete().eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> incrementView(String id) async {
    try {
      // Kein RPC fuer atomares Inkrement -- Read-then-write reicht fuer eine
      // ungefaehre View-Zahl, gelegentliche verlorene Updates sind ok.
      final row = await _client
          .from('listings')
          .select('view_count')
          .eq('id', id)
          .single();
      final current = row['view_count'] as int;
      await _client
          .from('listings')
          .update({'view_count': current + 1})
          .eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<List<String>> manufacturers() async {
    try {
      final rows = await _client
          .from('listings')
          .select('manufacturer')
          .not('manufacturer', 'is', null)
          .limit(500);
      final values =
          rows.map((r) => r['manufacturer'] as String).toSet().toList()..sort();
      return values;
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> insertImage(
    String listingId, {
    required String storagePath,
    required ImageKind kind,
    required int sortOrder,
  }) async {
    try {
      await _client.from('listing_images').insert({
        'listing_id': listingId,
        'storage_path': storagePath,
        'kind': _imageKindToDb(kind),
        'sort_order': sortOrder,
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<List<String>> imagePaths(String listingId) async {
    try {
      final rows = await _client
          .from('listing_images')
          .select('storage_path')
          .eq('listing_id', listingId)
          .eq('kind', _imageKindToDb(ImageKind.photo))
          .order('sort_order');
      return rows.map((r) => r['storage_path'] as String).toList();
    } catch (error) {
      throw mapError(error);
    }
  }
}

String _conditionToDb(ListingCondition c) =>
    c == ListingCondition.leichteDefekte ? 'leichte_defekte' : c.name;

String _imageKindToDb(ImageKind k) => switch (k) {
  ImageKind.photo => 'photo',
  ImageKind.fMarking => 'f_marking',
  ImageKind.ownershipProof => 'ownership_proof',
};

String _sortToDb(SortOption sort) => switch (sort) {
  SortOption.newest => 'newest',
  SortOption.priceAsc => 'price_asc',
  SortOption.priceDesc => 'price_desc',
  SortOption.distance => 'distance',
};
