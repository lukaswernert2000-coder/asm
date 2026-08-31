import 'package:asm/features/listings/presentation/widgets/listing_detail/seller_card.dart';
import 'package:asm/features/profile/domain/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Profile _seller({bool isCommercial = false, String? commercialName}) {
  return Profile(
    id: 's1',
    username: 'trader99',
    isCommercial: isCommercial,
    commercialName: commercialName,
    role: UserRole.user,
    createdAt: DateTime(2026, 2),
    lastSeenAt: DateTime(2026, 8, 29),
  );
}

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('zeigt Name, Mitglied-seit und aktive Inserate', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SellerCard(seller: _seller(), activeListingsCount: 3, onTap: () {}),
      ),
    );

    expect(find.text('trader99'), findsOneWidget);
    expect(find.textContaining('01.02.2026'), findsOneWidget);
    expect(find.text('3 aktive Inserate'), findsOneWidget);
  });

  testWidgets('zeigt keine Inserate-Zeile bei 0 aktiven Inseraten', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        SellerCard(seller: _seller(), activeListingsCount: 0, onTap: () {}),
      ),
    );

    expect(find.textContaining('aktive Inserate'), findsNothing);
  });

  testWidgets('zeigt Gewerblich-Badge nur bei isCommercial', (tester) async {
    await tester.pumpWidget(
      _wrap(
        SellerCard(
          seller: _seller(isCommercial: true, commercialName: 'Airsoft OHG'),
          activeListingsCount: 1,
          onTap: () {},
        ),
      ),
    );

    expect(find.text('Airsoft OHG'), findsOneWidget);
  });

  testWidgets('Tap ruft onTap auf', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(
        SellerCard(
          seller: _seller(),
          activeListingsCount: 1,
          onTap: () => tapped = true,
        ),
      ),
    );

    await tester.tap(find.byType(SellerCard));

    expect(tapped, isTrue);
  });
}
