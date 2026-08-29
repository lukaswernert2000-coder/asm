import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRepository {
  Future<Profile> byId(String id);
  Future<Profile?> current();
}

class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<Profile> byId(String id) async {
    try {
      final row = await _client.from('profiles').select().eq('id', id).single();
      return Profile.fromJson(row);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<Profile?> current() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;
    return byId(userId);
  }
}
