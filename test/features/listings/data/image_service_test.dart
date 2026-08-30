import 'dart:io';

import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/listings/data/image_service.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late ImageService service;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    service = ImageService(client);
  });

  group('upload', () {
    test('wirft AuthRequiredException ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => service.upload(
          File('unused.jpg'),
          listingId: 'l1',
          kind: ImageKind.photo,
        ),
        throwsA(isA<AuthRequiredException>()),
      );
    });
  });

  group('deleteAll', () {
    test('wirft AuthRequiredException ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => service.deleteAll(listingId: 'l1'),
        throwsA(isA<AuthRequiredException>()),
      );
    });
  });
}
