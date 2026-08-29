import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/moderation/domain/report_reason.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ModerationRepository {
  Future<void> reportUser(
    String userId,
    ReportReason reason, {
    String? details,
  });
  Future<void> blockUser(String userId);
}

class SupabaseModerationRepository implements ModerationRepository {
  SupabaseModerationRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<void> reportUser(
    String userId,
    ReportReason reason, {
    String? details,
  }) async {
    final reporterId = _client.auth.currentUser?.id;
    if (reporterId == null) throw const AuthRequiredException();
    try {
      await _client.from('reports').insert({
        'reporter_id': reporterId,
        'target_type': 'user',
        'target_id': userId,
        'reason': reason.dbValue,
        'details': details,
      });
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> blockUser(String userId) async {
    final blockerId = _client.auth.currentUser?.id;
    if (blockerId == null) throw const AuthRequiredException();
    try {
      await _client.from('blocks').insert({
        'blocker_id': blockerId,
        'blocked_id': userId,
      });
    } catch (error) {
      throw mapError(error);
    }
  }
}
