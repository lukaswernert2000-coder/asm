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
  Future<void> unblockUser(String userId);

  /// IDs der von mir blockierten Nutzer (Task 7.1, "Einstellungen").
  Future<List<String>> blockedUserIds();

  /// Ob ICH [userId] blockiert habe -- nicht umgekehrt: `blocks_own` in
  /// `0004_social.sql` erlaubt nur das Lesen der eigenen `blocker_id`-Zeilen,
  /// ein blockierter Account kann also nicht clientseitig erkennen, dass er
  /// selbst blockiert wurde. Fuers Sperren des Chat-Eingabefelds reicht die
  /// eigene Blockierrichtung -- die Gegenrichtung faengt die RLS-Policy aus
  /// `0014_blocks_stop_messaging.sql` beim eigentlichen Senden ab.
  Future<bool> isBlockedByMe(String userId);
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

  @override
  Future<void> unblockUser(String userId) async {
    final blockerId = _client.auth.currentUser?.id;
    if (blockerId == null) throw const AuthRequiredException();
    try {
      await _client
          .from('blocks')
          .delete()
          .eq('blocker_id', blockerId)
          .eq('blocked_id', userId);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<List<String>> blockedUserIds() async {
    final blockerId = _client.auth.currentUser?.id;
    if (blockerId == null) return const [];
    try {
      final rows = await _client
          .from('blocks')
          .select('blocked_id')
          .eq('blocker_id', blockerId)
          .order('created_at', ascending: false);
      return rows.map((r) => r['blocked_id'] as String).toList();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<bool> isBlockedByMe(String userId) async {
    final blockerId = _client.auth.currentUser?.id;
    if (blockerId == null) return false;
    try {
      final rows = await _client
          .from('blocks')
          .select('blocked_id')
          .eq('blocker_id', blockerId)
          .eq('blocked_id', userId)
          .limit(1);
      return rows.isNotEmpty;
    } catch (error) {
      throw mapError(error);
    }
  }
}
