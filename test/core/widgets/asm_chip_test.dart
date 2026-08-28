import 'package:asm/core/theme/asm_colors.dart';
import 'package:asm/core/widgets/asm_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: Center(child: child)));

BoxDecoration _decoration(WidgetTester tester) {
  final container = tester.widget<Container>(find.byType(Container));
  return container.decoration! as BoxDecoration;
}

void main() {
  testWidgets('inaktiv nutzt surfaceRaised/textSecondary/border', (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmChip(label: 'Langwaffen', selected: false),
    ));

    final decoration = _decoration(tester);
    expect(decoration.color, AsmColors.surfaceRaised);
    expect(decoration.border!.top.color, AsmColors.border);

    final text = tester.widget<Text>(find.text('Langwaffen'));
    expect(text.style?.color, AsmColors.textSecondary);
  });

  testWidgets('aktiv nutzt brand@22%/brandBright', (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmChip(label: 'Langwaffen', selected: true),
    ));

    final decoration = _decoration(tester);
    expect(decoration.color, AsmColors.brand.withValues(alpha: 0.22));
    expect(decoration.border!.top.color, AsmColors.brandBright);

    final text = tester.widget<Text>(find.text('Langwaffen'));
    expect(text.style?.color, AsmColors.brandBright);
  });

  testWidgets('hat die Hoehe 34', (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmChip(label: 'Langwaffen', selected: false),
    ));

    final size = tester.getSize(find.byType(AsmChip));
    expect(size.height, 34);
  });

  testWidgets('rendert das optionale Leading-Icon bei 16px', (tester) async {
    await tester.pumpWidget(_wrap(
      const AsmChip(label: 'Aktiv', selected: false, icon: LucideIcons.check),
    ));

    final icon = tester.widget<Icon>(find.byType(Icon));
    expect(icon.size, 16);
  });

  testWidgets('Tap ruft onTap auf', (tester) async {
    var tapped = false;
    await tester.pumpWidget(_wrap(
      AsmChip(label: 'Langwaffen', selected: false, onTap: () => tapped = true),
    ));

    await tester.tap(find.byType(AsmChip));
    expect(tapped, isTrue);
  });
}
