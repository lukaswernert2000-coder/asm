import 'package:asm/core/storage/shared_preferences_provider.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/fake_shared_preferences.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  group('listingViewModeProvider', () {
    test('faellt ohne gespeicherten Wert auf grid zurueck', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await fakeSharedPreferences(),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(listingViewModeProvider), ListingViewMode.grid);
    });

    test('liest einen gespeicherten Wert', () async {
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(
            await fakeSharedPreferences(
              listingViewMode: ListingViewMode.list,
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(listingViewModeProvider), ListingViewMode.list);
    });

    // setListingViewMode() nimmt ein WidgetRef (gleiches Muster wie
    // markOnboardingSeen) -- ueber den echten Umschalter-Button in
    // CategoryScreen getestet, nicht isoliert mit einem konstruierten Ref.
  });

  test('categoryFeedProvider ruft search() mit dem Filter auf', () async {
    final repository = MockListingRepository();
    const filter = ListingFilter(categorySlug: 'langwaffen');
    final summary = ListingSummary(
      id: 'l1',
      title: 'Test-Inserat',
      priceCents: 100,
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
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async => (items: [summary], total: 1));

    final container = ProviderContainer(
      overrides: [listingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(categoryFeedProvider(filter).future);

    expect(result.items, [summary]);
    expect(result.total, 1);
  });

  test('listingByIdProvider ruft byId() mit der ID auf', () async {
    final repository = MockListingRepository();
    final listing = Listing(
      id: 'l1',
      sellerId: 's1',
      categoryId: 'c1',
      title: 'G36 S-AEG mit Tuning-Gearbox',
      description: 'x' * 40,
      priceCents: 35000,
      negotiable: false,
      isGiveaway: false,
      acceptsSwap: false,
      condition: ListingCondition.gebraucht,
      status: ListingStatus.active,
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
    when(() => repository.byId('l1')).thenAnswer((_) async => listing);

    final container = ProviderContainer(
      overrides: [listingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(listingByIdProvider('l1').future);

    expect(result, listing);
  });

  test('listingImagePathsProvider ruft imagePaths() mit der ID auf', () async {
    final repository = MockListingRepository();
    when(
      () => repository.imagePaths('l1'),
    ).thenAnswer((_) async => ['u1/l1/photo_a.jpg', 'u1/l1/photo_b.jpg']);

    final container = ProviderContainer(
      overrides: [listingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(
      listingImagePathsProvider('l1').future,
    );

    expect(result, ['u1/l1/photo_a.jpg', 'u1/l1/photo_b.jpg']);
  });

  test(
    'listingsBySellerStatusProvider ruft bySeller() mit Verkaeufer und Status auf',
    () async {
      final repository = MockListingRepository();
      when(
        () => repository.bySeller('u1', status: ListingStatus.draft),
      ).thenAnswer((_) async => []);

      final container = ProviderContainer(
        overrides: [listingRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(container.dispose);

      final result = await container.read(
        listingsBySellerStatusProvider((
          sellerId: 'u1',
          status: ListingStatus.draft,
        )).future,
      );

      expect(result, isEmpty);
      verify(
        () => repository.bySeller('u1', status: ListingStatus.draft),
      ).called(1);
    },
  );
}
