import 'package:asm/features/auth/data/auth_repository.dart';
import 'package:asm/features/auth/domain/asm_user.dart';
import 'package:asm/features/auth/presentation/auth_controller.dart';
import 'package:asm/features/listings/data/image_service.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/listings/presentation/my_listings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

class MockImageService extends Mock implements ImageService {}

const _user = AsmUser(id: 'u1', email: 'a@b.de', emailConfirmed: true);

Listing _listing({
  String id = 'l1',
  ListingStatus status = ListingStatus.active,
  DateTime? bumpedAt,
  DateTime? publishedAt,
}) => Listing(
  id: id,
  sellerId: 'u1',
  categoryId: 'c1',
  title: 'G36 S-AEG mit Tuning-Gearbox',
  description: 'x' * 40,
  priceCents: 35000,
  negotiable: false,
  isGiveaway: false,
  acceptsSwap: false,
  condition: ListingCondition.gebraucht,
  status: status,
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
  bumpedAt: bumpedAt,
  publishedAt: publishedAt,
);

void main() {
  late MockAuthRepository authRepository;
  late MockListingRepository listingRepository;
  late MockImageService imageService;

  setUp(() {
    authRepository = MockAuthRepository();
    listingRepository = MockListingRepository();
    imageService = MockImageService();
    when(() => authRepository.authStateChanges())
        .thenAnswer((_) => Stream.value(_user));
    for (final status in ListingStatus.values) {
      when(
        () => listingRepository.bySeller('u1', status: status),
      ).thenAnswer((_) async => []);
    }
  });

  Future<ProviderContainer> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
        imageServiceProvider.overrideWithValue(imageService),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/my-listings',
      routes: [
        GoRoute(
          path: '/my-listings',
          builder: (context, state) => const MyListingsScreen(),
        ),
        GoRoute(
          path: '/listing/:id/edit',
          builder: (context, state) =>
              Scaffold(body: Text('edit:${state.pathParameters['id']}')),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('zeigt die vier Tabs Aktiv/Reserviert/Verkauft/Entwuerfe', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Aktiv'), findsOneWidget);
    expect(find.text('Reserviert'), findsOneWidget);
    expect(find.text('Verkauft'), findsOneWidget);
    expect(find.text('Entwürfe'), findsOneWidget);
  });

  testWidgets('Aktiv-Tab zeigt die aktiven Inserate mit Titel und Preis', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => [_listing()]);

    await pumpScreen(tester);

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(find.text('350,00 €'), findsOneWidget);
  });

  testWidgets('Reserviert-Tab zeigt einen eigenen Leerzustand', (
    tester,
  ) async {
    await pumpScreen(tester);

    await tester.tap(find.text('Reserviert'));
    await tester.pumpAndSettle();

    expect(find.text('Keine reservierten Inserate'), findsOneWidget);
  });

  testWidgets('Tab-Wechsel zu Verkauft laedt und zeigt verkaufte Inserate', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.sold),
    ).thenAnswer((_) async => [_listing(id: 'l2', status: ListingStatus.sold)]);

    await pumpScreen(tester);
    await tester.tap(find.text('Verkauft'));
    await tester.pumpAndSettle();

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
  });

  testWidgets(
    'Aktionsmenue eines aktiven Inserats zeigt alle fuenf Aktionen',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer(
        (_) async => [
          _listing(
            publishedAt: DateTime.now().subtract(const Duration(days: 20)),
          ),
        ],
      );

      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();

      expect(find.text('Bearbeiten'), findsOneWidget);
      expect(find.text('Hochschieben'), findsOneWidget);
      expect(find.text('Als reserviert markieren'), findsOneWidget);
      expect(find.text('Als verkauft markieren'), findsOneWidget);
      expect(find.text('Löschen'), findsOneWidget);
    },
  );

  testWidgets(
    'Aktionsmenue eines verkauften Inserats zeigt nur Bearbeiten und Loeschen',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.sold),
      ).thenAnswer((_) async => [_listing(status: ListingStatus.sold)]);

      await pumpScreen(tester);
      await tester.tap(find.text('Verkauft'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();

      expect(find.text('Bearbeiten'), findsOneWidget);
      expect(find.text('Löschen'), findsOneWidget);
      expect(find.text('Hochschieben'), findsNothing);
      expect(find.text('Als reserviert markieren'), findsNothing);
      expect(find.text('Als verkauft markieren'), findsNothing);
    },
  );

  testWidgets(
    'Aktionsmenue eines reservierten Inserats bietet "Als aktiv markieren" an -- '
    'Reservierungen fallen in der Praxis oft durch',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.reserved),
      ).thenAnswer((_) async => [_listing(status: ListingStatus.reserved)]);

      await pumpScreen(tester);
      await tester.tap(find.text('Reserviert'));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();

      expect(find.text('Als aktiv markieren'), findsOneWidget);
      expect(find.text('Als reserviert markieren'), findsNothing);
    },
  );

  testWidgets('Als aktiv markieren ruft setStatus(active) auf', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.reserved),
    ).thenAnswer((_) async => [_listing(status: ListingStatus.reserved)]);
    when(
      () => listingRepository.setStatus('l1', ListingStatus.active),
    ).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.tap(find.text('Reserviert'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('listingActions_l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Als aktiv markieren'));
    await tester.pumpAndSettle();

    verify(
      () => listingRepository.setStatus('l1', ListingStatus.active),
    ).called(1);
  });

  testWidgets(
    'Hochschieben ist deaktiviert und zeigt die Resttage innerhalb der 14-Tage-Sperre',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer(
        (_) async => [
          _listing(bumpedAt: DateTime.now().subtract(const Duration(days: 5))),
        ],
      );

      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();

      expect(find.text('Noch 9 Tage'), findsOneWidget);
      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('Hochschieben'),
          matching: find.byType(ListTile),
        ),
      );
      expect(tile.onTap, isNull);
    },
  );

  testWidgets('Bearbeiten navigiert zur Bearbeiten-Route mit der ID', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => [_listing()]);

    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('listingActions_l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bearbeiten'));
    await tester.pumpAndSettle();

    expect(find.text('edit:l1'), findsOneWidget);
  });

  testWidgets('Hochschieben ausserhalb der Sperre ruft bump() auf', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer(
      (_) async => [
        _listing(
          publishedAt: DateTime.now().subtract(const Duration(days: 20)),
        ),
      ],
    );
    when(() => listingRepository.bump('l1')).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('listingActions_l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hochschieben'));
    await tester.pumpAndSettle();

    verify(() => listingRepository.bump('l1')).called(1);
  });

  testWidgets('Als reserviert markieren ruft setStatus(reserved) auf', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => [_listing()]);
    when(
      () => listingRepository.setStatus('l1', ListingStatus.reserved),
    ).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('listingActions_l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Als reserviert markieren'));
    await tester.pumpAndSettle();

    verify(
      () => listingRepository.setStatus('l1', ListingStatus.reserved),
    ).called(1);
  });

  testWidgets('Als verkauft markieren ruft setStatus(sold) auf', (
    tester,
  ) async {
    when(
      () => listingRepository.bySeller('u1', status: ListingStatus.active),
    ).thenAnswer((_) async => [_listing()]);
    when(
      () => listingRepository.setStatus('l1', ListingStatus.sold),
    ).thenAnswer((_) async {});

    await pumpScreen(tester);
    await tester.tap(find.byKey(const Key('listingActions_l1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Als verkauft markieren'));
    await tester.pumpAndSettle();

    verify(
      () => listingRepository.setStatus('l1', ListingStatus.sold),
    ).called(1);
  });

  testWidgets(
    'Als verkauft markieren invalidiert auch listingByIdProvider (fuer '
    'Detailseite/Favoriten, die denselben Cache lesen)',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer((_) async => [_listing()]);
      when(
        () => listingRepository.setStatus('l1', ListingStatus.sold),
      ).thenAnswer((_) async {});
      when(() => listingRepository.byId('l1')).thenAnswer(
        (_) async => _listing(),
      );

      final container = await pumpScreen(tester);
      // Provider muss "lebendig" (beobachtet) sein, damit invalidate() einen
      // erneuten Fetch ausloest statt nur den Cache zu verwerfen.
      container.listen(listingByIdProvider('l1'), (_, _) {});
      await tester.pump();

      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Als verkauft markieren'));
      await tester.pumpAndSettle();

      // 1x durch das listen() oben, 1x erneut nach der Invalidierung.
      verify(() => listingRepository.byId('l1')).called(2);
    },
  );

  testWidgets(
    'Loeschen zeigt eine Bestaetigung; Abbrechen loescht nichts',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer((_) async => [_listing()]);

      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();

      expect(find.text('Inserat löschen?'), findsOneWidget);
      await tester.tap(find.text('Abbrechen'));
      await tester.pumpAndSettle();

      verifyNever(
        () => imageService.deleteAll(listingId: any(named: 'listingId')),
      );
      verifyNever(() => listingRepository.delete(any()));
    },
  );

  testWidgets(
    'Loeschen bestaetigen entfernt Storage-Objekte und dann das Inserat',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer((_) async => [_listing()]);
      when(
        () => imageService.deleteAll(listingId: 'l1'),
      ).thenAnswer((_) async {});
      when(() => listingRepository.delete('l1')).thenAnswer((_) async {});

      await pumpScreen(tester);
      await tester.tap(find.byKey(const Key('listingActions_l1')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Löschen'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(TextButton, 'Löschen'));
      await tester.pumpAndSettle();

      verify(() => imageService.deleteAll(listingId: 'l1')).called(1);
      verify(() => listingRepository.delete('l1')).called(1);
    },
  );
}
