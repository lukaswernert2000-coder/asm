import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/theme/asm_text_styles.dart';
import 'package:asm/core/widgets/asm_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

Color _borderColor(WidgetTester tester) {
  final container = tester.widget<Container>(find.byType(Container));
  final decoration = container.decoration! as BoxDecoration;
  return decoration.border!.top.color;
}

void main() {
  testWidgets('zeigt Label im label-Style ueber dem Feld', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(
      AsmTextField(controller: controller, label: 'E-Mail'),
    ));

    final labelText = tester.widget<Text>(find.text('E-Mail'));
    expect(labelText.style?.fontSize, AsmTextStyles.label.fontSize);
    expect(labelText.style?.fontWeight, AsmTextStyles.label.fontWeight);
  });

  testWidgets('Standard-Border ist AsmColors.border', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(
      AsmTextField(controller: controller, label: 'E-Mail'),
    ));

    expect(_borderColor(tester), AsmColors.border);
  });

  testWidgets('Fokus faerbt die Border brandBright', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(
      AsmTextField(controller: controller, label: 'E-Mail'),
    ));

    await tester.tap(find.byType(TextField));
    await tester.pump();

    expect(_borderColor(tester), AsmColors.brandBright);
  });

  testWidgets('Fehler faerbt die Border dangerText und zeigt Fehlertext',
      (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(
      AsmTextField(
        controller: controller,
        label: 'E-Mail',
        errorText: 'Pflichtfeld',
      ),
    ));

    expect(_borderColor(tester), AsmColors.dangerText);

    final errorWidget = tester.widget<Text>(find.text('Pflichtfeld'));
    expect(errorWidget.style?.fontSize, AsmTextStyles.bodyS.fontSize);
    expect(errorWidget.style?.color, AsmColors.dangerText);
  });

  testWidgets('maxLength zeigt einen Zeichenzaehler in bodyS/textTertiary',
      (tester) async {
    final controller = TextEditingController(text: 'Hallo');
    await tester.pumpWidget(_wrap(
      AsmTextField(controller: controller, label: 'Titel', maxLength: 80),
    ));

    final counter = tester.widget<Text>(find.text('5/80'));
    expect(counter.style?.fontSize, AsmTextStyles.bodyS.fontSize);
    expect(counter.style?.color, AsmColors.textTertiary);
  });
}
