import 'package:asm/features/chat/presentation/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt den Nachrichtentext und den Zeitstempel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ChatBubble(
          body: 'Ist das Gewehr noch da?',
          isOwn: false,
          timestamp: DateTime(2026, 9, 1, 14, 5),
        ),
      ),
    );

    expect(find.text('Ist das Gewehr noch da?'), findsOneWidget);
    expect(find.text('14:05'), findsOneWidget);
  });

  testWidgets(
    'Gelesen-Haken erscheint nur bei eigenen, gelesenen Nachrichten',
    (tester) async {
      await tester.pumpWidget(
        _wrap(
          ChatBubble(
            body: 'Ja, noch verfuegbar',
            isOwn: true,
            timestamp: DateTime(2026, 9, 1, 14, 6),
            isRead: true,
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.checkCheck), findsOneWidget);
    },
  );

  testWidgets('kein Gelesen-Haken bei fremden Nachrichten, auch wenn isRead', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        ChatBubble(
          body: 'Ja, noch verfuegbar',
          isOwn: false,
          timestamp: DateTime(2026, 9, 1, 14, 6),
          isRead: true,
        ),
      ),
    );

    expect(find.byIcon(LucideIcons.checkCheck), findsNothing);
  });

  testWidgets(
    'kein Gelesen-Haken, solange die eigene Nachricht ungelesen ist',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ChatBubble(
            body: 'Ja, noch verfuegbar',
            isOwn: true,
            timestamp: DateTime(2026, 9, 1, 14, 6),
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.checkCheck), findsNothing);
    },
  );

  testWidgets('status sending zeigt eine Sende-Anzeige statt Zeitstempel', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const ChatBubble(
          body: 'wird gesendet...',
          isOwn: true,
          status: ChatBubbleStatus.sending,
        ),
      ),
    );

    expect(find.byIcon(LucideIcons.clock), findsOneWidget);
  });

  testWidgets(
    'status failed zeigt ein Wiederholen-Symbol, Tap ruft onRetry auf',
    (tester) async {
      var retried = false;
      await tester.pumpWidget(
        _wrap(
          ChatBubble(
            body: 'nicht gesendet',
            isOwn: true,
            status: ChatBubbleStatus.failed,
            onRetry: () => retried = true,
          ),
        ),
      );

      expect(find.byIcon(LucideIcons.refreshCw), findsOneWidget);
      await tester.tap(find.byIcon(LucideIcons.refreshCw));
      await tester.pump();

      expect(retried, isTrue);
    },
  );
}
