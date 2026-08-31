import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_attribute_table.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Listing _listing({
  String? manufacturer,
  String? model,
  double? joule,
  PropulsionType? propulsion,
  String? caliber,
  bool hasFMarking = false,
  bool isModified = false,
}) {
  return Listing(
    id: 'l1',
    sellerId: 's1',
    categoryId: 'c1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    description: 'x' * 40,
    priceCents: 34900,
    negotiable: false,
    isGiveaway: false,
    acceptsSwap: false,
    condition: ListingCondition.gebraucht,
    status: ListingStatus.active,
    manufacturer: manufacturer,
    model: model,
    joule: joule,
    propulsion: propulsion,
    caliber: caliber,
    hasFMarking: hasFMarking,
    isModified: isModified,
    ships: true,
    pickupOnly: false,
    postalCode: '76133',
    city: 'Karlsruhe',
    lat: 49.01,
    lng: 8.4,
    viewCount: 0,
    createdAt: DateTime(2026, 8),
    updatedAt: DateTime(2026, 8),
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt nur befuellte Zeilen', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingAttributeTable(
          listing: _listing(manufacturer: 'Cyma', joule: 1.2),
        ),
      ),
    );

    expect(find.text('Hersteller'), findsOneWidget);
    expect(find.text('Cyma'), findsOneWidget);
    expect(find.text('Joule'), findsOneWidget);
    expect(find.text('Modell'), findsNothing);
    expect(find.text('Antriebsart'), findsNothing);
    expect(find.text('Kaliber'), findsNothing);
  });

  testWidgets('zeigt nichts, wenn kein Attribut befuellt ist', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(ListingAttributeTable(listing: _listing())));

    expect(find.byType(ListingAttributeTable), findsOneWidget);
    expect(find.text('Hersteller'), findsNothing);
    expect(find.text('F-Kennzeichen'), findsNothing);
    expect(find.text('Umgebaut'), findsNothing);
  });

  testWidgets('formatiert Joule mit Komma und Einheit', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingAttributeTable(listing: _listing(joule: 1.25))),
    );

    expect(find.text('1,25 J'), findsOneWidget);
  });

  testWidgets('zeigt Antriebsart-Label und Kaliber', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingAttributeTable(
          listing: _listing(propulsion: PropulsionType.saeg, caliber: '6mm'),
        ),
      ),
    );

    expect(find.text('S-AEG'), findsOneWidget);
    expect(find.text('6mm'), findsOneWidget);
  });

  testWidgets('F-Kennzeichen und Umgebaut nur bei true', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingAttributeTable(
          listing: _listing(hasFMarking: true, isModified: true),
        ),
      ),
    );

    expect(find.text('F-Kennzeichen'), findsOneWidget);
    expect(find.text('Umgebaut'), findsOneWidget);
  });
}
