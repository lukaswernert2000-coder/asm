import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Verallgemeinerte Fassung von `filter_sheet_interaction.dart`s
/// `scrollFilterSheetUntilVisible` fuer jede `ListView` mit fester Key --
/// scrollt per `ScrollableState.jumpTo` bis [finder] greift, statt eine
/// Drag-Geste zu simulieren (die auf einem `AsmTextField`s eigenem inneren
/// `Scrollable` landen und als Text-Selektion statt Listen-Scroll gewertet
/// werden koennte). `.first` trifft zuverlaessig das aeussere Scrollable,
/// weil es im Baum vor den inneren TextField-Scrollables seiner Kinder
/// liegt. Siehe DECISIONS.md, Task 3.4, fuer die urspruengliche Herleitung.
Future<void> scrollListUntilVisible(
  WidgetTester tester,
  Key listKey,
  Finder finder,
) async {
  final scrollable = find
      .descendant(of: find.byKey(listKey), matching: find.byType(Scrollable))
      .first;
  for (var i = 0; i < 30; i++) {
    if (finder.evaluate().isNotEmpty) break;
    final position = tester.state<ScrollableState>(scrollable).position;
    if (position.pixels >= position.maxScrollExtent) break;
    position.jumpTo(
      (position.pixels + 300).clamp(0.0, position.maxScrollExtent),
    );
    await tester.pump();
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> tapInList(WidgetTester tester, Key listKey, Finder finder) async {
  await scrollListUntilVisible(tester, listKey, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterTextInList(
  WidgetTester tester,
  Key listKey,
  Finder finder,
  String text,
) async {
  await scrollListUntilVisible(tester, listKey, finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
