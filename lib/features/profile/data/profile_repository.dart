import 'dart:typed_data';

import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class ProfileRepository {
  Future<Profile> byId(String id);
  Future<Profile?> current();
  Future<bool> isUsernameTaken(String username);

  /// Aktualisiert nur die uebergebenen Spalten (Patch, kein Full-Replace).
  /// Wichtig fuer `commercial_address`: die Spalte hat keinen Select-Grant
  /// (siehe DECISIONS.md), ein bestehender Wert kann also nie zurueckgelesen
  /// werden. Aufrufer duerfen den Key deshalb nur setzen, wenn der Nutzer ihn
  /// in dieser Sitzung tatsaechlich neu eingegeben hat -- sonst wuerde ein
  /// Update ohne den Key den gespeicherten Wert unveraendert lassen, mit dem
  /// Key auf "" ihn versehentlich loeschen.
  Future<void> update(String id, Map<String, dynamic> fields);

  /// Laedt komprimierte Bild-Bytes unter einem festen Dateinamen je Nutzer
  /// hoch (`upsert`, kein wachsender Verlauf alter Avatare) und gibt den
  /// Storage-Pfad zurueck, der dann in `update(..., {'avatar_path': path})`
  /// gespeichert wird.
  Future<String> uploadAvatar(String userId, Uint8List bytes);
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

  @override
  Future<bool> isUsernameTaken(String username) async {
    try {
      final rows = await _client
          .from('profiles')
          .select('id')
          .eq('username', username)
          .limit(1);
      return rows.isNotEmpty;
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<void> update(String id, Map<String, dynamic> fields) async {
    try {
      await _client.from('profiles').update(fields).eq('id', id);
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<String> uploadAvatar(String userId, Uint8List bytes) async {
    final path = '$userId/avatar.jpg';
    try {
      await _client.storage
          .from('avatars')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );
      return path;
    } catch (error) {
      throw mapError(error);
    }
  }
}
