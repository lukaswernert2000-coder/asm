import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:asm/features/search/presentation/search_history_providers.dart';
import 'package:asm/features/search/presentation/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';
import '../../../helpers/filter_sheet_interaction.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockCategoryRepository categoryRepository;
  late MockListingRepository listingRepository;

  const roots = [
    Category(
      id: 'p1',
      slug: 'langwaffen',
      name: 'Gewehre & MPs',
      sortOrder: 1,
      requiresAge18: true,
      requiresFMarking: true,
      requiresJoule: true,
      requiresPropulsion: true,
      isActive: true,
      icon: 'rifle',
    ),
  ];

  ListingSummary summary(String id) => ListingSummary(
    id: id,
    title: 'Inserat $id',
    priceCents: 10000,
    negotiable: false,
    condition: ListingCondition.gebraucht,
    status: ListingStatus.active,
    city: 'Karlsruhe',
    postalCode: '76133',
    hasFMarking: false,
    ships: false,
    bumpedAt: DateTime(2026, 8, 29),
    sellerId: 's1',
    categorySlug: 'langwaffen',
  );

  List<ListingSummary> summaries(int count, {int startAt = 0}) =>
      List.generate(count, (i) => summary('l${startAt + i}'));

  setUp(() {
    categoryRepository = MockCategoryRepository();
    listingRepository = MockListingRepository();
    when(() => categoryRepository.roots()).thenAnswer((_) async => roots);
    when(
      () => categoryRepository.bySlug('langwaffen'),
    ).thenAnswer((_) async => roots.single);
    when(
      () => categoryRepository.children('langwaffen'),
    ).thenAnswer((_) async => []);
  });

  Future<ProviderContainer> pumpScreen(
    WidgetTester tester, {
    List<String>? searchHistory,
  }) async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
        sharedPreferencesProvider.overrideWithValue(
          await fakeSharedPreferences(searchHistory: searchHistory),
        ),
      ],
    );
    addTearDown(container.dispose);
    final router = GoRouter(
      initialLocation: '/search',
      routes: [
        GoRoute(
          path: '/search',
          builder: (context, state) => const SearchScreen(),
        ),
        GoRoute(
          path: '/category/:slug',
          builder: (context, state) =>
              Text('Kategorie ${state.pathParameters['slug']}'),
        ),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    return container;
  }

  group('Leerer Zustand', () {
    testWidgets('zeigt beliebte Kategorien wenn Suchfeld leer', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Beliebte Kategorien'), findsOneWidget);
      expect(find.text('Gewehre & MPs'), findsOneWidget);
    });

    testWidgets('Tap auf Kategorie-Vorschlag navigiert zur Kategorie', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Gewehre & MPs'));
      await tester.pumpAndSettle();

      expect(find.text('Kategorie langwaffen'), findsOneWidget);
    });

    testWidgets('zeigt keinen Verlauf-Abschnitt ohne gespeicherte Suchen', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('Verlauf'), findsNothing);
    });

    testWidgets('zeigt gespeicherte Suchen als Verlauf', (tester) async {
      await pumpScreen(tester, searchHistory: ['pistole', 'aeg']);
      await tester.pumpAndSettle();

      expect(find.text('Verlauf'), findsOneWidget);
      expect(find.text('pistole'), findsOneWidget);
      expect(find.text('aeg'), findsOneWidget);
    });

    testWidgets('Loeschen-Icon entfernt genau einen Verlaufseintrag', (
      tester,
    ) async {
      await pumpScreen(tester, searchHistory: ['pistole', 'aeg']);
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('„pistole“ aus Verlauf entfernen'));
      await tester.pumpAndSettle();

      expect(find.text('pistole'), findsNothing);
      expect(find.text('aeg'), findsOneWidget);
    });

    testWidgets('Tap auf Verlaufseintrag fuehrt die Suche erneut aus', (
      tester,
    ) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'pistole')),
      ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

      await pumpScreen(tester, searchHistory: ['pistole']);
      await tester.pumpAndSettle();

      await tester.tap(find.text('pistole'));
      await tester.pumpAndSettle();

      expect(find.text('Inserat l1'), findsOneWidget);
    });
  });

  group('Debounce', () {
    testWidgets('tippen loest die Suche nicht sofort aus', (tester) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'pist')),
      ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pist');
      await tester.pump(const Duration(milliseconds: 100));

      verifyNever(
        () => listingRepository.search(const ListingFilter(query: 'pist')),
      );
    });

    testWidgets('nach 350 ms Pause wird gesucht', (tester) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'pist')),
      ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pist');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Inserat l1'), findsOneWidget);
    });

    testWidgets('eine abgeschlossene Suche landet im Verlauf', (
      tester,
    ) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'pist')),
      ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

      final container = await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pist');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(container.read(searchHistoryProvider), contains('pist'));
    });
  });

  group('Suchergebnisse', () {
    testWidgets('zeigt Leerzustand bei 0 Treffern', (tester) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'zzz')),
      ).thenAnswer((_) async => (items: <ListingSummary>[], total: 0));

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'zzz');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      expect(find.text('Keine Inserate gefunden'), findsOneWidget);
    });

    testWidgets('scrollen nahe ans Ende laedt die naechste Seite nach', (
      tester,
    ) async {
      when(
        () => listingRepository.search(const ListingFilter(query: 'pist')),
      ).thenAnswer((_) async => (items: summaries(20), total: 40));
      when(
        () => listingRepository.search(
          const ListingFilter(query: 'pist'),
          offset: 20,
        ),
      ).thenAnswer((_) async => (items: summaries(20, startAt: 20), total: 40));

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'pist');
      await tester.pump(const Duration(milliseconds: 350));
      await tester.pumpAndSettle();

      await tester.drag(find.byType(GridView), const Offset(0, -100000));
      await tester.pumpAndSettle();

      verify(
        () => listingRepository.search(
          const ListingFilter(query: 'pist'),
          offset: 20,
        ),
      ).called(1);
    });
  });

  // Suchscreen und Filter-Sheet ueberlappen sich im Baum (das Sheet legt
  // sich nur optisch ueber die Seite) -- "Gewehre & MPs" existiert dann
  // zweimal (Vorschlag im Hintergrund + Kategorie-Chip im Sheet). Auf den
  // Sheet-Inhalt eingrenzen, sonst meldet ensureVisible "Too many elements".
  Finder inFilterSheet(String text) => find.descendant(
    of: find.byKey(const Key('filterSheetList')),
    matching: find.text(text),
  );

  group('Filter-Sheet', () {
    testWidgets('zeigt kein Badge ohne aktive Filter', (tester) async {
      await pumpScreen(tester);
      await tester.pumpAndSettle();

      expect(find.text('0'), findsNothing);
    });

    testWidgets(
      'Filter anwenden zeigt Badge und aktiven Chip, filtert die Ergebnisse',
      (tester) async {
        when(
          () => listingRepository.search(
            const ListingFilter(categorySlug: 'langwaffen'),
          ),
        ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

        await pumpScreen(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Filter'));
        await tester.pumpAndSettle();
        await tapInFilterSheet(tester, inFilterSheet('Gewehre & MPs'));
        await tapInFilterSheet(tester, find.text('Anwenden'));

        expect(find.text('1'), findsOneWidget);
        expect(find.text('Kategorie: Gewehre & MPs'), findsOneWidget);
        expect(find.text('Inserat l1'), findsOneWidget);
      },
    );

    testWidgets('Entfernen eines aktiven Filters setzt ihn zurueck', (
      tester,
    ) async {
      when(
        () => listingRepository.search(
          const ListingFilter(categorySlug: 'langwaffen'),
        ),
      ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

      await pumpScreen(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter'));
      await tester.pumpAndSettle();
      await tapInFilterSheet(tester, inFilterSheet('Gewehre & MPs'));
      await tapInFilterSheet(tester, find.text('Anwenden'));
      expect(find.text('Kategorie: Gewehre & MPs'), findsOneWidget);

      await tester.tap(find.byTooltip('„Kategorie: Gewehre & MPs“ entfernen'));
      await tester.pumpAndSettle();

      expect(find.text('Kategorie: Gewehre & MPs'), findsNothing);
      expect(find.text('Beliebte Kategorien'), findsOneWidget);
    });
  });
}
