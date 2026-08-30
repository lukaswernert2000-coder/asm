import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Scrollt die Filter-Sheet-Liste (Key `filterSheetList`) direkt ueber
/// `ScrollableState.jumpTo`, bis [finder] greift, und interagiert danach.
///
/// Kein Drag-Gesture: jedes `AsmTextField` bringt ueber sein internes
/// `TextField` ein eigenes `Scrollable` mit, ein Drag-Startpunkt der
/// zufaellig darauf landet wuerde als Text-Selektion statt als
/// Listen-Scroll gewertet. `.first` trifft zuverlaessig das aeussere
/// Sheet-Scrollable, weil es im Baum vor den inneren TextField-Scrollables
/// seiner Kinder liegt. `ensureVisible` danach schiebt den (durch den
/// Sprung nur gebauten, nicht zwingend schon sichtbaren) Treffer vollends
/// in den sichtbaren Bereich, sonst schlaegt der Hit-Test beim Tippen fehl.
Future<void> scrollFilterSheetUntilVisible(
  WidgetTester tester,
  Finder finder,
) async {
  final scrollable = find
      .descendant(
        of: find.byKey(const Key('filterSheetList')),
        matching: find.byType(Scrollable),
      )
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

Future<void> tapInFilterSheet(WidgetTester tester, Finder finder) async {
  await scrollFilterSheetUntilVisible(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> enterTextInFilterSheet(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await scrollFilterSheetUntilVisible(tester, finder);
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}
