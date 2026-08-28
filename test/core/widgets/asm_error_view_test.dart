import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:asm/core/widgets/asm_empty_state.dart';
import 'package:asm/core/widgets/asm_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('zeigt die Fehlermeldung ueber AsmEmptyState', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AsmErrorView(message: 'Keine Verbindung', onRetry: () {}),
      ),
    );

    expect(find.byType(AsmEmptyState), findsOneWidget);
    expect(find.text('Keine Verbindung'), findsOneWidget);

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 48);
    expect(icon.color, AsmColors.textTertiary);
  });

  testWidgets('Tap auf den Retry-Button ruft onRetry auf', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      _wrap(
        AsmErrorView(
          message: 'Keine Verbindung',
          onRetry: () => retried = true,
        ),
      ),
    );

    expect(find.byType(AsmButton), findsOneWidget);
    await tester.tap(find.byType(AsmButton));
    expect(retried, isTrue);
  });
}
