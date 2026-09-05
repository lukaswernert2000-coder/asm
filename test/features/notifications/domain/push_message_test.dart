import 'package:asm/features/notifications/domain/push_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('conversationIdFromPushData', () {
    test('liest die conversationId aus den Daten einer Push-Nachricht', () {
      expect(
        conversationIdFromPushData({'conversationId': 'conv1'}),
        'conv1',
      );
    });

    test('liefert null ohne conversationId-Feld', () {
      expect(conversationIdFromPushData({'type': 'new_message'}), isNull);
    });
  });

  group('shouldSuppressPushForOpenChat', () {
    test('unterdrueckt, wenn die Nachricht zur gerade offenen Konversation gehoert', () {
      expect(
        shouldSuppressPushForOpenChat(
          data: {'conversationId': 'conv1'},
          openConversationId: 'conv1',
        ),
        isTrue,
      );
    });

    test('unterdrueckt nicht bei einer anderen Konversation', () {
      expect(
        shouldSuppressPushForOpenChat(
          data: {'conversationId': 'conv1'},
          openConversationId: 'conv2',
        ),
        isFalse,
      );
    });

    test('unterdrueckt nicht, wenn gerade kein Chat offen ist', () {
      expect(
        shouldSuppressPushForOpenChat(
          data: {'conversationId': 'conv1'},
          openConversationId: null,
        ),
        isFalse,
      );
    });

    test('unterdrueckt nicht ohne conversationId in den Daten', () {
      expect(
        shouldSuppressPushForOpenChat(
          data: const {},
          openConversationId: 'conv1',
        ),
        isFalse,
      );
    });
  });
}
