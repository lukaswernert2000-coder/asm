import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_legal_warning_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt den WaffG-Hinweis bei ueber 0,5 Joule', (tester) async {
    await tester.pumpWidget(
      _wrap(const ListingLegalWarningBox(joule: 1.2)),
    );

    expect(
      find.textContaining('Abgabe nur an Personen ab 18'),
      findsOneWidget,
    );
    expect(find.textContaining('§42a WaffG'), findsOneWidget);
  });

  testWidgets('zeigt nichts bei 0,5 Joule oder weniger', (tester) async {
    await tester.pumpWidget(_wrap(const ListingLegalWarningBox(joule: 0.5)));

    expect(find.byType(ListingLegalWarningBox), findsOneWidget);
    expect(find.textContaining('§42a WaffG'), findsNothing);
  });

  testWidgets('zeigt nichts ohne Joule-Angabe', (tester) async {
    await tester.pumpWidget(_wrap(const ListingLegalWarningBox(joule: null)));

    expect(find.textContaining('§42a WaffG'), findsNothing);
  });
}
