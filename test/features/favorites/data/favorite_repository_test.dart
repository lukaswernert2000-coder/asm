import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late FavoriteRepository repository;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repository = SupabaseFavoriteRepository(client);
  });

  group('isFavorited', () {
    test('liefert false ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await repository.isFavorited('l1');

      expect(result, isFalse);
    });
  });

  group('add', () {
    test('wirft AuthRequiredException ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => repository.add('l1'),
        throwsA(isA<AuthRequiredException>()),
      );
    });
  });

  group('remove', () {
    test('wirft AuthRequiredException ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => repository.remove('l1'),
        throwsA(isA<AuthRequiredException>()),
      );
    });
  });
}
