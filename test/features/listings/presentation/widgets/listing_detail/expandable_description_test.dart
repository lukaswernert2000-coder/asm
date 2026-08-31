import 'package:asm/features/listings/presentation/widgets/listing_detail/expandable_description.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 200, child: child)),
);

void main() {
  testWidgets('kurzer Text zeigt keinen Mehr-anzeigen-Button', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const ExpandableDescription(text: 'Kurz.')));

    expect(find.text('Mehr anzeigen'), findsNothing);
  });

  testWidgets(
    'langer Text ab 6 Zeilen zeigt Mehr anzeigen, Tap klappt aus',
    (tester) async {
      final longText = List.generate(
        40,
        (i) => 'Wort$i',
      ).join(' ');
      await tester.pumpWidget(
        _wrap(ExpandableDescription(text: longText)),
      );

      expect(find.text('Mehr anzeigen'), findsOneWidget);
      final collapsedText = tester.widget<Text>(find.text(longText));
      expect(collapsedText.maxLines, 6);

      await tester.tap(find.text('Mehr anzeigen'));
      await tester.pump();

      expect(find.text('Weniger anzeigen'), findsOneWidget);
      final expandedText = tester.widget<Text>(find.text(longText));
      expect(expandedText.maxLines, isNull);
    },
  );
}
