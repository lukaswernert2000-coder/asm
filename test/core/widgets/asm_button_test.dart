import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

void main() {
  testWidgets('primary rendert Label auf brandBright', (tester) async {
    await tester.pumpWidget(_wrap(
      AsmButton(label: 'Inserat aufgeben', onPressed: () {}),
    ));
    expect(find.text('Inserat aufgeben'), findsOneWidget);

    final container = tester.widget<Container>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(Container)).first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AsmColors.brandBright);
  });

  testWidgets('isLoading blendet das Label aus und zeigt einen Spinner',
      (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmButton(label: 'Speichern', isLoading: true),
    ));
    expect(find.text('Speichern'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('onPressed == null rendert den deaktivierten Zustand',
      (tester) async {
    await tester.pumpWidget(_wrap(const AsmButton(label: 'Aus')));

    // Deaktiviert = 38 % Deckkraft und kein InkWell-Callback
    final opacity = tester.widget<Opacity>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(Opacity)),
    );
    expect(opacity.opacity, closeTo(0.38, 0.001));

    final inkWell = tester.widget<InkWell>(
      find.descendant(of: find.byType(AsmButton), matching: find.byType(InkWell)),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('erfuellt die Mindestgroesse von 48dp', (tester) async {
    await tester.pumpWidget(_wrap(AsmButton(label: 'X', onPressed: () {})));
    final size = tester.getSize(find.byType(AsmButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });
}
