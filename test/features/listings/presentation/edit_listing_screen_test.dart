import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/presentation/edit_listing_screen.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../helpers/scrollable_list_interaction.dart';

class MockListingRepository extends Mock implements ListingRepository {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class FakeListingDraft extends Fake implements ListingDraft {}

const _listKey = Key('editListingList');

const _pistolenLeaf = Category(
  id: 'c1',
  slug: 'pistolen-revolver',
  name: 'Revolver',
  sortOrder: 1,
  requiresAge18: true,
  requiresFMarking: true,
  requiresJoule: true,
  requiresPropulsion: true,
  isActive: true,
  parentId: 'p1',
);

const _accessoryLeaf = Category(
  id: 'c2',
  slug: 'zubehoer-magazine',
  name: 'Magazine',
  sortOrder: 1,
  requiresAge18: false,
  requiresFMarking: false,
  requiresJoule: false,
  requiresPropulsion: false,
  isActive: true,
  parentId: 'p2',
);

Listing _listing({
  String id = 'l1',
  String categoryId = 'c2',
  bool hasFMarking = false,
}) => Listing(
  id: id,
  sellerId: 'u1',
  categoryId: categoryId,
  title: 'G36 S-AEG mit Tuning-Gearbox',
  description: 'Beschreibung mit mehr als dreissig Zeichen fuer den Test.',
  priceCents: 35000,
  negotiable: false,
  isGiveaway: false,
  acceptsSwap: false,
  condition: ListingCondition.gebraucht,
  status: ListingStatus.active,
  hasFMarking: hasFMarking,
  isModified: false,
  ships: true,
  pickupOnly: false,
  postalCode: '76133',
  city: 'Karlsruhe',
  lat: 49.0069,
  lng: 8.4037,
  viewCount: 3,
  createdAt: DateTime(2026, 8),
  updatedAt: DateTime(2026, 8),
);

void main() {
  late MockListingRepository listingRepository;
  late MockCategoryRepository categoryRepository;

  setUpAll(() {
    registerFallbackValue(FakeListingDraft());
  });

  setUp(() {
    listingRepository = MockListingRepository();
    categoryRepository = MockCategoryRepository();
    when(
      () => categoryRepository.all(),
    ).thenAnswer((_) async => [_pistolenLeaf, _accessoryLeaf]);
    when(
      () => listingRepository.manufacturers(),
    ).thenAnswer((_) async => ['ASG Corp', 'Airsoft GmbH']);
    when(
      () => listingRepository.update(any(), any()),
    ).thenAnswer((_) async {});
  });

  Future<Object?> resolvePlzFake(String plz) async {
    if (plz == '76133') return (city: 'Karlsruhe', lat: 49.0, lng: 8.4);
    return null;
  }

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    required Listing listing,
  }) async {
    // Grosse Viewport-Hoehe wie edit_profile_screen_test.dart -- der Screen
    // hat mehr Felder als der Bildschirm normalerweise zeigt, ohne das
    // waeren Praefill-Checks auf ausserhalb des Viewports gerenderte
    // (und damit nicht im Element-Baum gemountete) Felder ein Fehlalarm.
    tester.view.physicalSize = const Size(400, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    when(
      () => listingRepository.byId(listing.id),
    ).thenAnswer((_) async => listing);

    final container = ProviderContainer(
      overrides: [
        listingRepositoryProvider.overrideWithValue(listingRepository),
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        supabaseProvider.overrideWithValue(MockSupabaseClient()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: EditListingScreen(
            listingId: listing.id,
            resolvePlz: (plz) async =>
                await resolvePlzFake(plz)
                    as ({String city, double lat, double lng})?,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets('fuellt Titel, Beschreibung, Preis, Zustand und PLZ vor', (
    tester,
  ) async {
    await pumpScreen(tester, listing: _listing());

    expect(find.text('G36 S-AEG mit Tuning-Gearbox'), findsOneWidget);
    expect(
      find.text('Beschreibung mit mehr als dreissig Zeichen fuer den Test.'),
      findsOneWidget,
    );
    expect(find.text('350,00'), findsOneWidget);
    expect(find.text('76133'), findsOneWidget);
    expect(find.text('Karlsruhe'), findsOneWidget);
  });

  testWidgets(
    'zeigt Antriebsart/Joule/Kaliber nur wenn die Kategorie es verlangt',
    (tester) async {
      await pumpScreen(tester, listing: _listing());
      await scrollListUntilVisible(tester, _listKey, find.text('Modell'));
      expect(find.text('Antriebsart'), findsNothing);
      expect(find.text('Kaliber'), findsNothing);
    },
  );

  testWidgets(
    'zeigt Antriebsart/Joule/Kaliber wenn die Kategorie es verlangt',
    (tester) async {
      await pumpScreen(
        tester,
        listing: _listing(categoryId: 'c1', hasFMarking: true),
      );
      await scrollListUntilVisible(tester, _listKey, find.text('Antriebsart'));
      expect(find.text('Antriebsart'), findsOneWidget);
      await scrollListUntilVisible(tester, _listKey, find.text('Kaliber'));
      expect(find.text('Kaliber'), findsOneWidget);
    },
  );

  testWidgets('Speichern mit geleertem Titel zeigt einen Fehler', (
    tester,
  ) async {
    await pumpScreen(tester, listing: _listing());

    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('editListingTitle')),
      '',
    );
    await tapInList(tester, _listKey, find.byKey(const Key('editListingSave')));

    expect(find.text('Zwischen 10 und 80 Zeichen'), findsOneWidget);
    verifyNever(() => listingRepository.update(any(), any()));
  });

  testWidgets(
    'Speichern mit gueltigen Aenderungen ruft update() mit dem neuen Titel und Preis auf',
    (tester) async {
      await pumpScreen(tester, listing: _listing());

      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('editListingTitle')),
        'Ein neuer, gueltiger Titel',
      );
      await enterTextInList(
        tester,
        _listKey,
        find.byKey(const Key('editListingPrice')),
        '42,50',
      );
      await tapInList(
        tester,
        _listKey,
        find.byKey(const Key('editListingSave')),
      );

      final captured =
          verify(
                () => listingRepository.update('l1', captureAny()),
              ).captured.single
              as ListingDraft;
      expect(captured.title, 'Ein neuer, gueltiger Titel');
      expect(captured.priceCents, 4250);
      expect(captured.categoryId, 'c2');
      expect(captured.postalCode, '76133');
      expect(captured.city, 'Karlsruhe');
    },
  );

  testWidgets(
    'Speichern aktualisiert auch die "Meine Inserate"-Liste des Verkaeufers',
    (tester) async {
      when(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).thenAnswer((_) async => []);

      final container = await pumpScreen(tester, listing: _listing());
      // Provider muss "lebendig" (beobachtet) sein, damit invalidate() einen
      // erneuten Fetch ausloest statt nur den Cache zu verwerfen.
      container.listen(
        listingsBySellerStatusProvider((
          sellerId: 'u1',
          status: ListingStatus.active,
        )),
        (_, _) {},
      );
      await tester.pump();

      await tapInList(
        tester,
        _listKey,
        find.byKey(const Key('editListingSave')),
      );

      verify(
        () => listingRepository.bySeller('u1', status: ListingStatus.active),
      ).called(2);
    },
  );

  testWidgets('Hersteller-Autocomplete schlaegt bestehende Werte vor', (
    tester,
  ) async {
    await pumpScreen(tester, listing: _listing());

    await enterTextInList(
      tester,
      _listKey,
      find.byKey(const Key('editListingManufacturer')),
      'ASG',
    );

    expect(find.text('ASG Corp'), findsOneWidget);
    expect(find.text('Airsoft GmbH'), findsNothing);
  });
}
