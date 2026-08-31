import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/widgets/listing_detail/listing_price_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Listing _listing({
  bool negotiable = false,
  bool isGiveaway = false,
  bool acceptsSwap = false,
  int priceCents = 34900,
  ListingCondition condition = ListingCondition.gebraucht,
}) {
  return Listing(
    id: 'l1',
    sellerId: 's1',
    categoryId: 'c1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    description: 'x' * 40,
    priceCents: priceCents,
    negotiable: negotiable,
    isGiveaway: isGiveaway,
    acceptsSwap: acceptsSwap,
    condition: condition,
    status: ListingStatus.active,
    hasFMarking: false,
    isModified: false,
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
  testWidgets('zeigt den Preis ohne Badges bei Festpreis', (tester) async {
    await tester.pumpWidget(_wrap(ListingPriceHeader(listing: _listing())));

    expect(find.text('349,00 €'), findsOneWidget);
    expect(find.text('VB'), findsNothing);
    expect(find.text('Tausch möglich'), findsNothing);
  });

  testWidgets('zeigt VB bei verhandelbarem Preis', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingPriceHeader(listing: _listing(negotiable: true))),
    );

    expect(find.text('VB'), findsOneWidget);
  });

  testWidgets('zeigt Tausch moeglich bei acceptsSwap', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingPriceHeader(listing: _listing(acceptsSwap: true))),
    );

    expect(find.text('Tausch möglich'), findsOneWidget);
  });

  testWidgets('zeigt Zu verschenken statt eines Preises', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingPriceHeader(
          listing: _listing(isGiveaway: true, priceCents: 0),
        ),
      ),
    );

    expect(find.text('Zu verschenken'), findsOneWidget);
    expect(find.text('0,00 €'), findsNothing);
  });

  testWidgets('zeigt das Zustands-Label', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingPriceHeader(
          listing: _listing(condition: ListingCondition.neuwertig),
        ),
      ),
    );

    expect(find.text('Neuwertig'), findsOneWidget);
  });
}
