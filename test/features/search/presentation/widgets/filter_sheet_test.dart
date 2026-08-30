import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/search/presentation/widgets/filter_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/filter_sheet_interaction.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository categoryRepository;

  const pistolen = Category(
    id: 'p1',
    slug: 'pistolen',
    name: 'Pistolen',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
  );
  const revolver = Category(
    id: 'c1',
    slug: 'revolver',
    name: 'Revolver',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
    parentId: 'p1',
  );
  const zubehoer = Category(
    id: 'z1',
    slug: 'zubehoer',
    name: 'Zubehör',
    sortOrder: 2,
    requiresAge18: false,
    requiresFMarking: false,
    requiresJoule: false,
    requiresPropulsion: false,
    isActive: true,
  );

  setUp(() {
    categoryRepository = MockCategoryRepository();
    when(
      () => categoryRepository.roots(),
    ).thenAnswer((_) async => [pistolen, zubehoer]);
    when(
      () => categoryRepository.children('pistolen'),
    ).thenAnswer((_) async => [revolver]);
    when(
      () => categoryRepository.children('zubehoer'),
    ).thenAnswer((_) async => []);
    when(
      () => categoryRepository.bySlug('pistolen'),
    ).thenAnswer((_) async => pistolen);
    when(
      () => categoryRepository.bySlug('zubehoer'),
    ).thenAnswer((_) async => zubehoer);
  });

  Future<List<ListingFilter?>> pumpSheet(
    WidgetTester tester, {
    ListingFilter filter = const ListingFilter(),
    Future<({String city, double lat, double lng})?> Function(String plz)?
    resolvePlz,
  }) async {
    final results = <ListingFilter?>[];
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                results.add(
                  await showFilterSheet(
                    context,
                    filter: filter,
                    resolvePlz: resolvePlz ?? (_) async => null,
                  ),
                );
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('zeigt Root-Kategorien, Zustand, Antriebsart, Sortierung', (
    tester,
  ) async {
    await pumpSheet(tester);

    expect(find.text('Pistolen'), findsOneWidget);
    expect(find.text('Zubehör'), findsOneWidget);
    expect(find.text('Neuwertig'), findsOneWidget);
    await scrollFilterSheetUntilVisible(tester, find.text('Entfernung'));
    await tester.pumpAndSettle();
    expect(find.text('Neueste'), findsOneWidget);
    expect(find.text('Entfernung'), findsOneWidget);
    // Joule/Antriebsart ohne gewaehlte Kategorie ausgeblendet.
    expect(find.text('Joule-Bereich'), findsNothing);
    expect(find.text('Antriebsart'), findsNothing);
  });

  testWidgets(
    'Kategorie mit requiresJoule/requiresPropulsion blendet Joule und Antriebsart ein',
    (tester) async {
      await pumpSheet(tester);

      await tapInFilterSheet(tester, find.text('Pistolen'));

      expect(find.text('Revolver'), findsOneWidget);
      await scrollFilterSheetUntilVisible(tester, find.text('S-AEG'));
      await tester.pumpAndSettle();
      expect(find.text('S-AEG'), findsOneWidget);
      await scrollFilterSheetUntilVisible(tester, find.text('Joule-Bereich'));
      await tester.pumpAndSettle();
      expect(find.text('Joule-Bereich'), findsOneWidget);
    },
  );

  testWidgets(
    'Kategorie ohne requiresJoule/requiresPropulsion blendet beides nicht ein',
    (tester) async {
      await pumpSheet(tester);

      await tapInFilterSheet(tester, find.text('Zubehör'));

      expect(find.text('Joule-Bereich'), findsNothing);
      expect(find.text('Antriebsart'), findsNothing);
    },
  );

  testWidgets('Zustand-Chips sind mehrfach auswaehlbar', (tester) async {
    final results = await pumpSheet(tester);

    await tapInFilterSheet(tester, find.text('Neuwertig'));
    await tapInFilterSheet(tester, find.text('Gebraucht'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.conditions, [
      ListingCondition.neuwertig,
      ListingCondition.gebraucht,
    ]);
  });

  testWidgets('erneutes Tippen auf einen Zustand-Chip waehlt ihn wieder ab', (
    tester,
  ) async {
    final results = await pumpSheet(tester);

    await tapInFilterSheet(tester, find.text('Neuwertig'));
    await tapInFilterSheet(tester, find.text('Neuwertig'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.conditions, isNull);
  });

  testWidgets('Preis-Eingabefelder setzen min/max in Cent', (tester) async {
    final results = await pumpSheet(tester);

    await enterTextInFilterSheet(
      tester,
      find.byKey(const Key('filterMinPrice')),
      '20',
    );
    await enterTextInFilterSheet(
      tester,
      find.byKey(const Key('filterMaxPrice')),
      '150',
    );
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.minPrice, 2000);
    expect(results.single?.maxPrice, 15000);
  });

  testWidgets('Joule-RangeSlider setzt min/max Joule', (tester) async {
    final results = await pumpSheet(tester);
    await tapInFilterSheet(tester, find.text('Pistolen'));

    final sliderFinder = find.byKey(const Key('filterJouleSlider'));
    await scrollFilterSheetUntilVisible(tester, sliderFinder);
    await tester.pumpAndSettle();
    final slider = tester.widget<RangeSlider>(sliderFinder);
    slider.onChanged!(const RangeValues(0.5, 3));
    await tester.pumpAndSettle();
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.minJoule, 0.5);
    expect(results.single?.maxJoule, 3);
  });

  testWidgets('Versand-Chip setzt ships auf true', (tester) async {
    final results = await pumpSheet(tester);

    await tapInFilterSheet(tester, find.text('Versand möglich'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.ships, true);
  });

  testWidgets(
    'Umkreis-Chips und Entfernung-Sortierung sind ohne aufgeloeste PLZ deaktiviert',
    (tester) async {
      final results = await pumpSheet(tester);

      await tapInFilterSheet(tester, find.text('25 km'));
      await tapInFilterSheet(tester, find.text('Entfernung'));
      await tapInFilterSheet(tester, find.text('Anwenden'));

      expect(results.single?.radiusKm, isNull);
      expect(results.single?.sort, SortOption.newest);
    },
  );

  testWidgets(
    'gueltige PLZ aktiviert Umkreis-Chips und Entfernung-Sortierung',
    (tester) async {
      final results = await pumpSheet(
        tester,
        resolvePlz: (plz) async =>
            plz == '76133' ? (city: 'Karlsruhe', lat: 49.01, lng: 8.4) : null,
      );

      await enterTextInFilterSheet(
        tester,
        find.byKey(const Key('filterPlz')),
        '76133',
      );

      expect(find.text('Karlsruhe'), findsOneWidget);

      await tapInFilterSheet(tester, find.text('25 km'));
      await tapInFilterSheet(tester, find.text('Entfernung'));
      await tapInFilterSheet(tester, find.text('Anwenden'));

      expect(results.single?.radiusKm, 25);
      expect(results.single?.lat, 49.01);
      expect(results.single?.lng, 8.4);
      expect(results.single?.sort, SortOption.distance);
    },
  );

  testWidgets('unbekannte PLZ zeigt eine Fehlermeldung', (tester) async {
    await pumpSheet(tester, resolvePlz: (plz) async => null);

    await enterTextInFilterSheet(
      tester,
      find.byKey(const Key('filterPlz')),
      '00000',
    );

    expect(find.text('Unbekannte Postleitzahl'), findsOneWidget);
  });

  testWidgets('"ganz DE" setzt radiusKm zurueck auf null', (tester) async {
    final results = await pumpSheet(
      tester,
      filter: const ListingFilter(lat: 49.01, lng: 8.4, radiusKm: 10),
      resolvePlz: (_) async => null,
    );

    await tapInFilterSheet(tester, find.text('ganz DE'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.radiusKm, isNull);
    expect(results.single?.lat, 49.01);
  });

  testWidgets('Sortierung ist einfachauswahl', (tester) async {
    final results = await pumpSheet(tester);

    await tapInFilterSheet(tester, find.text('Preis aufsteigend'));
    await tapInFilterSheet(tester, find.text('Preis absteigend'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.sort, SortOption.priceDesc);
  });

  testWidgets('Sheet startet vorbefuellt mit dem uebergebenen Filter', (
    tester,
  ) async {
    final results = await pumpSheet(
      tester,
      filter: const ListingFilter(
        categorySlug: 'zubehoer',
        conditions: [ListingCondition.neu],
        sort: SortOption.priceAsc,
      ),
    );

    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single?.categorySlug, 'zubehoer');
    expect(results.single?.conditions, [ListingCondition.neu]);
    expect(results.single?.sort, SortOption.priceAsc);
  });

  testWidgets('"Alle zuruecksetzen" setzt alles bis auf query zurueck', (
    tester,
  ) async {
    final results = await pumpSheet(
      tester,
      filter: const ListingFilter(
        query: 'aeg',
        categorySlug: 'zubehoer',
        minPrice: 1000,
        conditions: [ListingCondition.neu],
        sort: SortOption.priceAsc,
      ),
    );

    await tapInFilterSheet(tester, find.text('Alle zurücksetzen'));
    await tapInFilterSheet(tester, find.text('Anwenden'));

    expect(results.single, const ListingFilter(query: 'aeg'));
  });

  testWidgets('Wegtippen auf den Hintergrund ohne Anwenden liefert null', (
    tester,
  ) async {
    final results = await pumpSheet(tester);

    await tapInFilterSheet(tester, find.text('Neuwertig'));
    // Modal-Barriere oberhalb des Sheets antippen, um ohne "Anwenden" zu
    // schliessen (das Sheet nimmt bei initialChildSize 0.9 nur die unteren
    // 90 % ein).
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();

    expect(results.single, isNull);
  });
}
