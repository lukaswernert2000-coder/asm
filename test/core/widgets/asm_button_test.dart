import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('primary rendert Label auf brandBright', (tester) async {
    await tester.pumpWidget(
      _wrap(
        AsmButton(label: 'Inserat aufgeben', onPressed: () {}),
      ),
    );
    expect(find.text('Inserat aufgeben'), findsOneWidget);

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AsmButton),
            matching: find.byType(Container),
          )
          .first,
    );
    final decoration = container.decoration! as BoxDecoration;
    expect(decoration.color, AsmColors.brandBright);
  });

  testWidgets('isLoading blendet das Label aus und zeigt einen Spinner', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        const AsmButton(label: 'Speichern', isLoading: true),
      ),
    );
    expect(find.text('Speichern'), findsNothing);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('onPressed == null rendert den deaktivierten Zustand', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(const AsmButton(label: 'Aus')));

    // Deaktiviert = 38 % Deckkraft und kein InkWell-Callback
    final opacity = tester.widget<Opacity>(
      find.descendant(
        of: find.byType(AsmButton),
        matching: find.byType(Opacity),
      ),
    );
    expect(opacity.opacity, closeTo(0.38, 0.001));

    final inkWell = tester.widget<InkWell>(
      find.descendant(
        of: find.byType(AsmButton),
        matching: find.byType(InkWell),
      ),
    );
    expect(inkWell.onTap, isNull);
  });

  testWidgets('erfuellt die Mindestgroesse von 48dp', (tester) async {
    await tester.pumpWidget(_wrap(AsmButton(label: 'X', onPressed: () {})));
    final size = tester.getSize(find.byType(AsmButton));
    expect(size.height, greaterThanOrEqualTo(48));
  });

  testWidgets(
    'langes Label in schmaler Expanded-Breite ueberlaeuft nicht (RenderFlex)',
    (tester) async {
      // Regression: in einer Bottom-Bar neben zwei Icon-Buttons (Task 5.1,
      // ListingBottomBar) bekommt AsmButton nur eine schmale Expanded-Breite
      // -- das interne Row (mainAxisSize: min) lief bisher ueber, weil das
      // Label nie in ein Flexible/Ellipsis eingepackt war. Braucht ein
      // schmales, telefon-typisches Viewport, um das zu reproduzieren.
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Row(
              children: [
                Expanded(
                  child: AsmButton(
                    label: 'Nachricht schreiben',
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 48),
                const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    },
  );
}
