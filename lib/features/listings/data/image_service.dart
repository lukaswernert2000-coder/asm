import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Bild-Pipeline fuers Inserat-Erstellen: Auswahl, Kompression vor dem
/// Upload (spart Datenvolumen und Zeit), Ablage in Supabase Storage.
class ImageService {
  ImageService(this._client, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final SupabaseClient _client;
  final ImagePicker _picker;

  Future<List<XFile>> pickFromGallery({int max = 12}) {
    return _picker.pickMultiImage(limit: max);
  }

  Future<XFile?> pickFromCamera() {
    return _picker.pickImage(source: ImageSource.camera);
  }

  /// Verkleinert auf max. 1600 px lange Kante bei Qualitaet 80, JPEG.
  ///
  /// `flutter_image_compress`s minWidth/minHeight sind trotz des Namens
  /// keine Ober-, sondern Untergrenzen: das Plugin waehlt den kleinsten
  /// Skalierungsfaktor, der beide Grenzen noch einhaelt
  /// (`s = max(minWidth/originalWidth, minHeight/originalHeight)`), nicht
  /// automatisch die lange Kante. Deshalb wird hier vorher dekodiert, um zu
  /// wissen, welche Kante die lange ist, und nur deren Grenze auf 1600
  /// gesetzt (die andere auf 1, damit sie nie bindend wird).
  Future<File> compress(File file) async {
    final bytes = await file.readAsBytes();
    final original = await _decodeDimensions(bytes);
    final isLandscape = original.width >= original.height;
    final longEdge = isLandscape ? original.width : original.height;
    final targetLongEdge = longEdge > 1600 ? 1600 : longEdge;

    final targetPath = '${file.path}_compressed.jpg';
    final result = await FlutterImageCompress.compressAndGetFile(
      file.path,
      targetPath,
      minWidth: isLandscape ? targetLongEdge : 1,
      minHeight: isLandscape ? 1 : targetLongEdge,
      quality: 80,
    );
    if (result == null) {
      throw const ValidationException(
        'Dieses Bild konnte nicht verarbeitet werden.',
      );
    }
    return File(result.path);
  }

  Future<ui.Image> _decodeDimensions(Uint8List bytes) {
    final completer = Completer<ui.Image>();
    ui.decodeImageFromList(bytes, completer.complete);
    return completer.future;
  }

  /// Laedt [file] fuer den aktuell angemeldeten Nutzer hoch.
  /// Pfadkonvention: `listing-images/<user_id>/<listing_id>/<kind>_<token>.jpg`.
  Future<String> upload(
    File file, {
    required String listingId,
    required ImageKind kind,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw const AuthRequiredException();
    }
    final path = '$userId/$listingId/${kind.name}_${_uniqueToken()}.jpg';
    try {
      final bytes = await file.readAsBytes();
      await _client.storage
          .from('listing-images')
          .uploadBinary(
            path,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );
      return path;
    } catch (error) {
      throw mapError(error);
    }
  }

  String _uniqueToken() {
    final bytes = List<int>.generate(8, (_) => Random.secure().nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }
}
