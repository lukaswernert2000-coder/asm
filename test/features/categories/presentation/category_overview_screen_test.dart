import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_overview_screen.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
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

  const categories = [
    Category(
      id: 'c1',
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
    Category(
      id: 'c2',
      slug: 'zubehoer',
      name: 'Zubehör',
      sortOrder: 2,
      requiresAge18: false,
      requiresFMarking: false,
      requiresJoule: false,
      requiresPropulsion: false,
      isActive: true,
      icon: 'accessory',
    ),
  ];

  setUp(() {
    categoryRepository = MockCategoryRepository();
    listingRepository = MockListingRepository();
    when(() => categoryRepository.roots()).thenAnswer((_) async => categories);
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
        child: const MaterialApp(home: CategoryOverviewScreen()),
      ),
    );
  }

  testWidgets('zeigt alle Wurzel-Kategorien als Kacheln', (tester) async {
    when(
      () => listingRepository.search(const ListingFilter()),
    ).thenAnswer((_) async => (items: <ListingSummary>[], total: 0));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Gewehre & MPs'), findsOneWidget);
    expect(find.text('Zubehör'), findsOneWidget);
  });

  testWidgets('zeigt "Neu eingestellt" mit den neuesten Inseraten', (
    tester,
  ) async {
    final summary = ListingSummary(
      id: 'l1',
      title: 'Frisches Inserat',
      priceCents: 5000,
      negotiable: false,
      condition: ListingCondition.neu,
      status: ListingStatus.active,
      city: 'Berlin',
      postalCode: '10115',
      hasFMarking: false,
      ships: false,
      bumpedAt: DateTime(2026, 8, 29),
      sellerId: 's1',
      categorySlug: 'zubehoer',
    );
    when(
      () => listingRepository.search(const ListingFilter()),
    ).thenAnswer((_) async => (items: [summary], total: 1));

    await pumpScreen(tester);
    await tester.pumpAndSettle();

    expect(find.text('Neu eingestellt'), findsOneWidget);
    expect(find.text('Frisches Inserat'), findsOneWidget);
  });
}
