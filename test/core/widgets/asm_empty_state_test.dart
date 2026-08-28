import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('rendert Icon 48px in textTertiary und Titel in titleM', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AsmEmptyState(icon: LucideIcons.search, title: 'Nichts gefunden'),
      ),
    );

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 48);
    expect(icon.color, AsmColors.textTertiary);

    final title = tester.widget<Text>(find.text('Nichts gefunden'));
    expect(title.style?.fontSize, AsmTextStyles.titleM.fontSize);
    expect(title.style?.fontWeight, AsmTextStyles.titleM.fontWeight);
  });

  testWidgets('message gesetzt zeigt Beschreibung in bodyM/textSecondary', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AsmEmptyState(
          icon: LucideIcons.search,
          title: 'Nichts gefunden',
          message: 'Versuch andere Filter.',
        ),
      ),
    );

    final message = tester.widget<Text>(find.text('Versuch andere Filter.'));
    expect(message.style?.fontSize, AsmTextStyles.bodyM.fontSize);
    expect(message.style?.color, AsmColors.textSecondary);
  });

  testWidgets('message == null zeigt keine Beschreibung', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AsmEmptyState(icon: LucideIcons.search, title: 'Nichts gefunden'),
      ),
    );

    expect(find.text('Versuch andere Filter.'), findsNothing);
  });

  testWidgets('action wird gerendert, wenn gesetzt', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AsmEmptyState(
          icon: LucideIcons.search,
          title: 'Nichts gefunden',
          action: Text('Filter zuruecksetzen'),
        ),
      ),
    );

    expect(find.text('Filter zuruecksetzen'), findsOneWidget);
  });

  testWidgets('Inhalt ist auf maximal 320 Breite begrenzt', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AsmEmptyState(icon: LucideIcons.search, title: 'Nichts gefunden'),
      ),
    );

    final finder = find.byWidgetPredicate(
      (widget) =>
          widget is ConstrainedBox && widget.constraints.maxWidth == 320,
    );
    expect(finder, findsOneWidget);
  });
}
