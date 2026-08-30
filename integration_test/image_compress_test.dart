import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:asm/features/listings/data/image_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

/// Erzeugt echtes Pixel-fuer-Pixel-Rauschen (wie ein Foto, nicht wie eine
/// Grafik mit flaechigen Farben) -- ein Volltonbild oder grobe Kacheln
/// liessen sich als PNG zu gut wegkomprimieren (lange gleiche Byte-Laeufe)
/// und wuerden den Original-vs-komprimiert-Groessenvergleich verfaelschen,
/// weil PNG auf sowas viel besser komprimiert als das JPEG-Ergebnis danach.
Future<Uint8List> _noisyPng(int width, int height) async {
  final random = math.Random(7);
  final pixels = Uint8List(width * height * 4);
  for (var i = 0; i < pixels.length; i += 4) {
    pixels[i] = random.nextInt(256);
    pixels[i + 1] = random.nextInt(256);
    pixels[i + 2] = random.nextInt(256);
    pixels[i + 3] = 255;
  }
  final completer = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    pixels,
    width,
    height,
    ui.PixelFormat.rgba8888,
    completer.complete,
  );
  final image = await completer.future;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData!.buffer.asUint8List();
}

Future<ui.Image> _decode(Uint8List bytes) {
  final completer = Completer<ui.Image>();
  ui.decodeImageFromList(bytes, completer.complete);
  return completer.future;
}

/// `flutter_image_compress` komprimiert nativ (Kotlin/Swift) -- ein normaler
/// `flutter test` laeuft auf dem Host (hier Windows) und hat dafuer keine
/// Plattform-Implementierung ("Windows is not supported"), deshalb kann
/// dieser Test nicht in test/ liegen. Nicht Teil von CI (kein Geraet dort).
/// Manuell ausfuehren mit einem verbundenen Geraet/Emulator:
/// `flutter test integration_test/image_compress_test.dart -d <device-id>`
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'compress verkleinert ein 4000x3000-Testbild auf max. 1600 px lange '
    'Kante und die Datei wird kleiner',
    (tester) async {
      final tempDir = await Directory.systemTemp.createTemp(
        'image_compress_test_',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final bytes = await _noisyPng(4000, 3000);
      final original = File('${tempDir.path}/original.png')
        ..writeAsBytesSync(bytes);

      final service = ImageService(MockSupabaseClient());
      final compressed = await service.compress(original);

      expect(compressed.existsSync(), isTrue);
      final decoded = await _decode(compressed.readAsBytesSync());
      expect(decoded.width, 1600);
      expect(decoded.height, 1200);
      expect(compressed.lengthSync(), lessThan(original.lengthSync()));
    },
  );

  testWidgets(
    'compress skaliert ein bereits kleines Bild nicht hoch',
    (tester) async {
      final tempDir = await Directory.systemTemp.createTemp(
        'image_compress_test_',
      );
      addTearDown(() => tempDir.deleteSync(recursive: true));

      final bytes = await _noisyPng(800, 600);
      final original = File('${tempDir.path}/original.png')
        ..writeAsBytesSync(bytes);

      final service = ImageService(MockSupabaseClient());
      final compressed = await service.compress(original);

      final decoded = await _decode(compressed.readAsBytesSync());
      expect(decoded.width, 800);
      expect(decoded.height, 600);
    },
  );
}
