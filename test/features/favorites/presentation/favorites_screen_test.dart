import 'package:asm/core/router/app_router.dart';
import 'package:asm/core/router/routes.dart';
import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_detail_screen.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockListingRepository listingRepository;
  late MockFavoriteRepository favoriteRepository;
  late MockAuthRepository authRepository;

  const me = AsmUser(id: 'me', email: 'a@b.de', emailConfirmed: true);

  Listing listing({
    String id = 'l1',
    ListingStatus status = ListingStatus.active,
  }) => Listing(
    id: id,
    sellerId: 's1',
    categoryId: 'c1',
    title: 'G36 S-AEG mit Tuning-Gearbox',
    description: 'x' * 40,
    priceCents: 34900,
    negotiable: false,
    isGiveaway: false,
    acceptsSwap: false,
    condition: ListingCondition.gebraucht,
    status: status,
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

  setUp(() {
    listingRepository = MockListingRepository();
    favoriteRepository = MockFavoriteRepository();
    authRepository = MockAuthRepository();
    when(() => authRepository.authStateChanges()).thenAnswer(
      (_) => Stream.value(me),
    );
    when(() => listingRepository.imagePaths(any())).thenAnswer(
      (_) async => <String>[],
    );
  });

  Future<void> pumpBriefly(WidgetTester tester) async {
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<GoRouter> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        listingRepositoryProvider.overrideWithValue(listingRepository),
        favoriteRepositoryProvider.overrideWithValue(favoriteRepository),
        authRepositoryProvider.overrideWithValue(authRepository),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = container.read(appRouterProvider);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();
    router.go(AsmRoutes.favorites);
    await pumpBriefly(tester);
    return router;
  }

  testWidgets('zeigt einen leeren Zustand ohne Favoriten', (tester) async {
    when(() => favoriteRepository.myListingIds()).thenAnswer(
      (_) async => [],
    );

    await pumpScreen(tester);

    expect(find.text('Noch keine Favoriten'), findsOneWidget);
  });

  testWidgets('zeigt eine Zeile pro Favorit mit Titel und Preis', (
    tester,
  ) async {
    when(() => favoriteRepository.myListingIds()).thenAnswer(
      (_) async => ['l1'],
    );
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );

    await pumpScreen(tester);

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(find.text('349,00 €'), findsOneWidget);
    expect(find.text('Verkauft'), findsNothing);
  });

  testWidgets('zeigt Verkauft-Badge bei verkauftem Favorit', (tester) async {
    when(() => favoriteRepository.myListingIds()).thenAnswer(
      (_) async => ['l1'],
    );
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(status: ListingStatus.sold),
    );

    await pumpScreen(tester);

    expect(find.text('Verkauft'), findsOneWidget);
  });

  testWidgets('Wischen entfernt einen Favoriten', (tester) async {
    when(() => favoriteRepository.myListingIds()).thenAnswer(
      (_) async => ['l1'],
    );
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );
    when(() => favoriteRepository.remove('l1')).thenAnswer((_) async {});

    await pumpScreen(tester);
    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);

    await tester.drag(
      find.byType(Dismissible),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    verify(() => favoriteRepository.remove('l1')).called(1);
    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsNothing);
  });

  testWidgets('Tap auf eine Zeile navigiert zur Detailseite', (
    tester,
  ) async {
    when(() => favoriteRepository.myListingIds()).thenAnswer(
      (_) async => ['l1'],
    );
    when(() => listingRepository.byId('l1')).thenAnswer(
      (_) async => listing(),
    );
    when(() => favoriteRepository.isFavorited('l1')).thenAnswer(
      (_) async => true,
    );
    when(
      () => listingRepository.bySeller('s1', status: any(named: 'status')),
    ).thenAnswer((_) async => []);
    when(() => listingRepository.incrementView('l1')).thenAnswer(
      (_) async {},
    );

    await pumpScreen(tester);
    await tester.tap(find.text('G36 S-AEG mit Tuning-Gearbox'));
    await pumpBriefly(tester);

    expect(find.byType(ListingDetailScreen), findsOneWidget);
  });
}
