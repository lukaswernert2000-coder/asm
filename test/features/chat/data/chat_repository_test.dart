import 'dart:async';

import 'package:asm/features/chat/data/chat_repository.dart';
import 'package:asm/features/chat/domain/conversation.dart';
import 'package:asm/features/chat/domain/message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

Map<String, dynamic> _messageRow({
  required String id,
  required String body,
}) => {
  'id': id,
  'conversation_id': 'c1',
  'sender_id': 'u1',
  'body': body,
  'image_path': null,
  'created_at': '2026-09-01T10:00:00.000Z',
  'read_at': null,
};

Map<String, dynamic> _conversationRow({
  required String id,
  String? lastMessageAt,
}) => {
  'id': id,
  'listing_id': 'l1',
  'buyer_id': 'u1',
  'seller_id': 'u2',
  'created_at': '2026-09-01T09:00:00.000Z',
  'last_message_at': lastMessageAt,
};

void main() {
  late MockSupabaseClient client;

  setUp(() {
    client = MockSupabaseClient();
  });

  group('messages', () {
    test(
      'gibt neue Nachrichten ueber denselben Stream aus, ohne dass neu '
      'geladen wird',
      () async {
        final controller = StreamController<List<Map<String, dynamic>>>();
        addTearDown(controller.close);

        final repository = SupabaseChatRepository(
          client,
          messageStreamCaller: (conversationId) => controller.stream,
        );

        final emissions = <List<Message>>[];
        final subscription = repository.messages('c1').listen(emissions.add);
        addTearDown(subscription.cancel);

        controller.add([_messageRow(id: 'm1', body: 'Hallo')]);
        await Future<void>.delayed(Duration.zero);

        controller.add([
          _messageRow(id: 'm1', body: 'Hallo'),
          _messageRow(id: 'm2', body: 'Ist das noch da?'),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(2));
        expect(emissions[0], hasLength(1));
        expect(emissions[1], hasLength(2));
        expect(emissions[1].last.body, 'Ist das noch da?');
      },
    );

    test('ruft den Stream-Caller mit der uebergebenen conversationId auf', () {
      String? capturedId;
      final repository = SupabaseChatRepository(
        client,
        messageStreamCaller: (conversationId) {
          capturedId = conversationId;
          return const Stream.empty();
        },
      );

      repository.messages('c42').listen((_) {});

      expect(capturedId, 'c42');
    });
  });

  group('conversations', () {
    test(
      'gibt neue Konversationen ueber denselben Stream aus, ohne dass neu '
      'geladen wird',
      () async {
        final controller = StreamController<List<Map<String, dynamic>>>();
        addTearDown(controller.close);

        final repository = SupabaseChatRepository(
          client,
          conversationStreamCaller: () => controller.stream,
        );

        final emissions = <List<Conversation>>[];
        final subscription = repository.conversations().listen(
          emissions.add,
        );
        addTearDown(subscription.cancel);

        controller.add([_conversationRow(id: 'conv1')]);
        await Future<void>.delayed(Duration.zero);

        controller.add([
          _conversationRow(
            id: 'conv1',
            lastMessageAt: '2026-09-01T10:05:00.000Z',
          ),
        ]);
        await Future<void>.delayed(Duration.zero);

        expect(emissions, hasLength(2));
        expect(emissions[0].single.lastMessageAt, isNull);
        expect(emissions[1].single.lastMessageAt, isNotNull);
      },
    );
  });
}
