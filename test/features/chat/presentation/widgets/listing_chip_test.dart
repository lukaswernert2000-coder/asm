import 'package:asm/features/chat/presentation/widgets/listing_chip.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Listing _listing() => Listing(
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

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt Titel und Preis des Inserats', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingChip(listing: _listing(), imageUrl: null, onTap: () {})),
    );

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(find.text('349,00 €'), findsOneWidget);
  });

  testWidgets('Tap ruft onTap auf', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        ListingChip(
          listing: _listing(),
          imageUrl: null,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(ListingChip));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
