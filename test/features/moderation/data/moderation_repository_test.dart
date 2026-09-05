import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/moderation/data/moderation_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

void main() {
  late MockSupabaseClient client;
  late MockGoTrueClient auth;
  late ModerationRepository repository;

  setUp(() {
    client = MockSupabaseClient();
    auth = MockGoTrueClient();
    when(() => client.auth).thenReturn(auth);
    repository = SupabaseModerationRepository(client);
  });

  group('unblockUser', () {
    test('wirft AuthRequiredException ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      expect(
        () => repository.unblockUser('u1'),
        throwsA(isA<AuthRequiredException>()),
      );
    });
  });

  group('blockedUserIds', () {
    test('liefert leere Liste ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await repository.blockedUserIds();

      expect(result, isEmpty);
    });
  });

  group('isBlockedByMe', () {
    test('liefert false ohne angemeldeten Nutzer', () async {
      when(() => auth.currentUser).thenReturn(null);

      final result = await repository.isBlockedByMe('u1');

      expect(result, isFalse);
    });
  });
}
