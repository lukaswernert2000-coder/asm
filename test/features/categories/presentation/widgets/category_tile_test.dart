import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/widgets/category_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(
    body: Center(child: SizedBox(width: 110, height: 110, child: child)),
  ),
);

const _category = Category(
  id: 'c1',
  slug: 'langwaffen',
  name: 'Gewehre & MPs',
  sortOrder: 1,
  requiresAge18: true,
  requiresFMarking: true,
  requiresJoule: true,
  requiresPropulsion: true,
  isActive: true,
  icon: 'rifle',
);

void main() {
  testWidgets('zeigt Namen und Icon der Kategorie', (tester) async {
    await tester.pumpWidget(
      _wrap(CategoryTile(category: _category, onTap: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gewehre & MPs'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
  });

  testWidgets('Tap loest onTap aus', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(CategoryTile(category: _category, onTap: () => tapped = true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(CategoryTile));
    expect(tapped, isTrue);
  });
}
