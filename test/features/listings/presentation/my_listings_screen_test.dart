import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/my_listings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockListingRepository listingRepository;

  const user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);
  final listing = Listing(
    id: 'l1',
    sellerId: 'u1',
    categoryId: 'c1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    description: 'x' * 40,
    priceCents: 35000,
    negotiable: false,
    isGiveaway: false,
    acceptsSwap: false,
    condition: ListingCondition.gebraucht,
    status: ListingStatus.active,
    hasFMarking: true,
    isModified: false,
    ships: true,
    pickupOnly: false,
    postalCode: '76133',
    city: 'Karlsruhe',
    lat: 49.01,
    lng: 8.4,
    viewCount: 3,
    createdAt: DateTime(2026, 8),
    updatedAt: DateTime(2026, 8),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    listingRepository = MockListingRepository();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(user));
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: MyListingsScreen()),
      ),
    );
  }

  testWidgets('zeigt die eigenen aktiven Inserate mit Titel und Preis', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => [listing]);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(find.text('350,00 €'), findsOneWidget);
  });

  testWidgets('zeigt einen Leerzustand ohne aktive Inserate', (tester) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => []);

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Noch keine Inserate'), findsOneWidget);
  });
}
