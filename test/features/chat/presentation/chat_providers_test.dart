import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/presentation/chat_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockChatRepository extends Mock implements ChatRepository {}

void main() {
  late MockChatRepository chatRepository;

  setUp(() {
    chatRepository = MockChatRepository();
  });

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [chatRepositoryProvider.overrideWithValue(chatRepository)],
    );
    addTearDown(c.dispose);
    return c;
  }

  group('PendingMessagesNotifier', () {
    test('send() haengt sofort einen pending Eintrag an und entfernt ihn '
        'nach erfolgreichem Senden wieder', () async {
      when(() => chatRepository.send('conv1', 'Hallo!')).thenAnswer(
        (_) async {},
      );
      final c = container();
      final notifier = c.read(pendingMessagesProvider('conv1').notifier);

      final future = notifier.send('Hallo!');
      expect(c.read(pendingMessagesProvider('conv1')), hasLength(1));
      expect(c.read(pendingMessagesProvider('conv1')).single.failed, isFalse);

      await future;

      expect(c.read(pendingMessagesProvider('conv1')), isEmpty);
    });

    test('markiert den Eintrag bei einem AppException-Fehler als failed, '
        'statt ihn zu entfernen', () async {
      when(() => chatRepository.send('conv1', 'Hallo!')).thenThrow(
        const NetworkException(),
      );
      final c = container();
      final notifier = c.read(pendingMessagesProvider('conv1').notifier);

      await notifier.send('Hallo!');

      final pending = c.read(pendingMessagesProvider('conv1'));
      expect(pending, hasLength(1));
      expect(pending.single.failed, isTrue);
      expect(pending.single.body, 'Hallo!');
    });

    test('retry() versucht denselben Text erneut und entfernt ihn bei '
        'Erfolg', () async {
      when(() => chatRepository.send('conv1', 'Hallo!')).thenThrow(
        const NetworkException(),
      );
      final c = container();
      final notifier = c.read(pendingMessagesProvider('conv1').notifier);
      await notifier.send('Hallo!');
      final localId = c.read(pendingMessagesProvider('conv1')).single.localId;

      when(() => chatRepository.send('conv1', 'Hallo!')).thenAnswer(
        (_) async {},
      );
      await notifier.retry(localId);

      expect(c.read(pendingMessagesProvider('conv1')), isEmpty);
      verify(() => chatRepository.send('conv1', 'Hallo!')).called(2);
    });
  });
}
