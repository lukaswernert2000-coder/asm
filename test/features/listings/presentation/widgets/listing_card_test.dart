import 'package:asm/core/config/app_config.dart';
import 'package:asm/core/widgets/asm_network_image.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_image_url.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/widgets/listing_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child, {double width = 180}) => MaterialApp(
  home: Scaffold(
    body: SizedBox(width: width, height: 280, child: child),
  ),
);

ListingSummary _summary({
  ListingCondition condition = ListingCondition.gebraucht,
  ListingStatus status = ListingStatus.active,
  bool hasFMarking = false,
  bool negotiable = false,
  bool ships = false,
  double? distanceKm,
}) {
  return ListingSummary(
    id: 'l1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    priceCents: 34900,
    negotiable: negotiable,
    condition: condition,
    status: status,
    city: 'Karlsruhe',
    postalCode: '76133',
    hasFMarking: hasFMarking,
    ships: ships,
    bumpedAt: DateTime(2026, 8, 29, 10),
    sellerId: 's1',
    categorySlug: 'langwaffen',
    distanceKm: distanceKm,
  );
}

void main() {
  testWidgets('grid: zeigt Titel, Preis und Ort', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingCard.grid(summary: _summary(), onTap: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(find.text('349,00 €'), findsOneWidget);
    expect(find.textContaining('76133 Karlsruhe'), findsOneWidget);
  });

  testWidgets('baut die Bild-URL aus coverPath statt sie roh zu reichen', (
    tester,
  ) async {
    final summary = _summary().copyWith(coverPath: 'u1/l1/photo_a.jpg');
    await tester.pumpWidget(
      _wrap(ListingCard.grid(summary: summary, onTap: () {})),
    );
    // Kein pumpAndSettle: AsmNetworkImage zeigt bei gesetztem Pfad Shimmer,
    // waehrend CachedNetworkImage laedt -- eine Dauer-Animation, auf die
    // pumpAndSettle nie zurueckkehrt (gleiches bekanntes Problem wie bei
    // AsmSkeleton, siehe public_profile_screen_test.dart). Der Pfad steht
    // aber schon nach dem ersten Frame fest, ein einzelner pump() reicht.
    await tester.pump();

    final image = tester.widget<AsmNetworkImage>(
      find.byType(AsmNetworkImage),
    );
    expect(
      image.path,
      listingImageUrl(
        supabaseUrl: AppConfig.supabaseUrl,
        path: 'u1/l1/photo_a.jpg',
      ),
    );
  });

  testWidgets('Tap auf die Karte loest onTap aus', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(ListingCard.grid(summary: _summary(), onTap: () => tapped = true)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ListingCard));
    expect(tapped, isTrue);
  });

  testWidgets('zeigt VB bei verhandelbarem Preis', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingCard.grid(summary: _summary(negotiable: true), onTap: () {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VB'), findsOneWidget);
  });

  testWidgets('zeigt kein VB bei Festpreis', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingCard.grid(summary: _summary(), onTap: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('VB'), findsNothing);
  });

  testWidgets('zeigt VERKAUFT-Overlay bei Status sold', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingCard.grid(
          summary: _summary(status: ListingStatus.sold),
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('VERKAUFT'), findsOneWidget);
  });

  testWidgets('zeigt RESERVIERT-Overlay bei Status reserved', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingCard.grid(
          summary: _summary(status: ListingStatus.reserved),
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('RESERVIERT'), findsOneWidget);
  });

  testWidgets('kein Status-Overlay bei Status active', (tester) async {
    await tester.pumpWidget(
      _wrap(ListingCard.grid(summary: _summary(), onTap: () {})),
    );
    await tester.pumpAndSettle();

    expect(find.text('VERKAUFT'), findsNothing);
    expect(find.text('RESERVIERT'), findsNothing);
  });

  testWidgets('list-Variante rendert ohne Fehler', (tester) async {
    await tester.pumpWidget(
      _wrap(
        ListingCard.list(summary: _summary(ships: true), onTap: () {}),
        width: 360,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(ListingCard), findsOneWidget);
  });
}
