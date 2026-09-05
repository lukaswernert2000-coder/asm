import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class DeviceTokenRepository {
  Future<void> register({required String token, required String platform});
  Future<void> unregister(String token);
}

class SupabaseDeviceTokenRepository implements DeviceTokenRepository {
  SupabaseDeviceTokenRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> register({
    required String token,
    required String platform,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw const AuthRequiredException();
    try {
      await _client.from('device_tokens').upsert({
        'token': token,
        'user_id': userId,
        'platform': platform,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> unregister(String token) async {
    try {
      await _client.from('device_tokens').delete().eq('token', token);
    } catch (error) {
      throw mapError(error);
    }
  }
}
