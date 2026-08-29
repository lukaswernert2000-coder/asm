import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_checkbox.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

final Finder _boxFinder = find.descendant(
  of: find.byType(AsmCheckbox),
  matching: find.byType(Container),
);

Color _boxBorderColor(WidgetTester tester) {
  final box = tester.widget<Container>(_boxFinder);
  final decoration = box.decoration! as BoxDecoration;
  return decoration.border!.top.color;
}

void main() {
  testWidgets('unchecked zeigt Border in AsmColors.border, kein Haken', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsmCheckbox(
          value: false,
          onChanged: (_) {},
          label: const Text('AGB akzeptieren'),
        ),
      ),
    );

    expect(_boxBorderColor(tester), AsmColors.border);
    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('checked fuellt die Box mit brandBright und zeigt einen Haken', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsmCheckbox(
          value: true,
          onChanged: (_) {},
          label: const Text('AGB akzeptieren'),
        ),
      ),
    );

    final box = tester.widget<Container>(_boxFinder);
    final decoration = box.decoration! as BoxDecoration;
    expect(decoration.color, AsmColors.brandBright);
  });

  testWidgets('Tap auf die Box ruft onChanged mit dem umgekehrten Wert auf', (
    tester,
  ) async {
    var lastValue = false;
    var callCount = 0;
    await tester.pumpWidget(
      _wrap(
        AsmCheckbox(
          value: false,
          onChanged: (v) {
            lastValue = v;
            callCount++;
          },
          label: const Text('AGB akzeptieren'),
        ),
      ),
    );

    await tester.tap(_boxFinder);

    expect(callCount, 1);
    expect(lastValue, isTrue);
  });

  testWidgets('errorText faerbt die Border dangerText und wird angezeigt', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        AsmCheckbox(
          value: false,
          onChanged: (_) {},
          label: const Text('AGB akzeptieren'),
          errorText: 'Bitte bestätige AGB und Datenschutz',
        ),
      ),
    );

    expect(_boxBorderColor(tester), AsmColors.dangerText);
    expect(find.text('Bitte bestätige AGB und Datenschutz'), findsOneWidget);
  });

  testWidgets('Tap auf einen Link im Label toggelt die Checkbox NICHT', (
    tester,
  ) async {
    var callCount = 0;
    var linkTapped = false;
    await tester.pumpWidget(
      _wrap(
        AsmCheckbox(
          value: false,
          onChanged: (_) => callCount++,
          label: Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Ich akzeptiere die '),
                TextSpan(
                  text: 'AGB',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => linkTapped = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.tapOnText(find.textRange.ofSubstring('AGB'));

    expect(linkTapped, isTrue);
    expect(callCount, 0);
  });
}
