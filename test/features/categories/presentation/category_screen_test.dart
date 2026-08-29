import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:asm/features/categories/presentation/category_screen.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockCategoryRepository categoryRepository;
  late MockListingRepository listingRepository;

  const parent = Category(
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
  );
  const child = Category(
    id: 'c1',
    slug: 'langwaffen-saeg',
    name: 'S-AEG',
    sortOrder: 1,
    requiresAge18: true,
    requiresFMarking: true,
    requiresJoule: true,
    requiresPropulsion: true,
    isActive: true,
    parentId: 'p1',
  );

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

  setUp(() {
    categoryRepository = MockCategoryRepository();
    listingRepository = MockListingRepository();
    when(
      () => categoryRepository.bySlug('langwaffen'),
    ).thenAnswer((_) async => parent);
    when(
      () => categoryRepository.children('langwaffen'),
    ).thenAnswer((_) async => [child]);
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        categoryRepositoryProvider.overrideWithValue(categoryRepository),
        listingRepositoryProvider.overrideWithValue(listingRepository),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: CategoryScreen(slug: 'langwaffen')),
      ),
    );
  }

  testWidgets('zeigt Kategorienamen, Unterkategorien-Chips und Feed', (
    tester,
  ) async {
    when(
      () => listingRepository.search(
        const ListingFilter(categorySlug: 'langwaffen'),
      ),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Gewehre & MPs'), findsOneWidget);
    expect(find.text('Alle'), findsOneWidget);
    expect(find.text('S-AEG'), findsOneWidget);
    expect(find.text('Inserat l1'), findsOneWidget);
  });

  testWidgets('Tap auf Unterkategorie-Chip filtert den Feed neu', (
    tester,
  ) async {
    when(
      () => listingRepository.search(
        const ListingFilter(categorySlug: 'langwaffen'),
      ),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 1));
    when(
      () => listingRepository.search(
        const ListingFilter(categorySlug: 'langwaffen-saeg'),
      ),
    ).thenAnswer((_) async => (items: [summary('l2')], total: 1));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Inserat l1'), findsOneWidget);

    await tester.tap(find.text('S-AEG'));
    await tester.pumpAndSettle();

    expect(find.text('Inserat l2'), findsOneWidget);
  });

  testWidgets('zeigt Leerzustand ohne Treffer', (tester) async {
    when(
      () => listingRepository.search(
        const ListingFilter(categorySlug: 'langwaffen'),
      ),
    ).thenAnswer((_) async => (items: <ListingSummary>[], total: 0));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Keine Inserate gefunden'), findsOneWidget);
  });
}
