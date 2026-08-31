import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Minimale Datenschicht fuer Task 5.1s Favoriten-Herz. Optimistisches
/// Umschalten mit Rollback ist erst Task 5.2 -- hier nur einfache
/// Lese-/Schreib-Operationen gegen die seit M1 bestehende `favorites`-Tabelle.
abstract interface class FavoriteRepository {
  Future<bool> isFavorited(String listingId);
  Future<void> add(String listingId);
  Future<void> remove(String listingId);
}

class SupabaseFavoriteRepository implements FavoriteRepository {
  SupabaseFavoriteRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<bool> isFavorited(String listingId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;
    try {
      final rows = await _client
          .from('favorites')
          .select('listing_id')
          .eq('user_id', userId)
          .eq('listing_id', listingId)
          .limit(1);
      return rows.isNotEmpty;
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> add(String listingId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthRequiredException();
    try {
      await _client.from('favorites').insert({
        'user_id': userId,
        'listing_id': listingId,
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> remove(String listingId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthRequiredException();
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', userId)
          .eq('listing_id', listingId);
    } catch (error) {
      throw mapError(error);
    }
  }
}
