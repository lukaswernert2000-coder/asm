import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/listings/data/listing_repository.dart';
import 'package:asm/features/listings/domain/listing.dart';
import 'package:asm/features/listings/domain/listing_filter.dart';
import 'package:asm/features/listings/domain/listing_summary.dart';
import 'package:asm/features/listings/presentation/listing_feed_controller.dart';
import 'package:asm/features/listings/presentation/listing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockListingRepository extends Mock implements ListingRepository {}

void main() {
  late MockListingRepository repository;
  const filter = ListingFilter(categorySlug: 'langwaffen');

  ListingSummary summary(String id) => ListingSummary(
    id: id,
    title: 'Inserat $id',
    priceCents: 1000,
    negotiable: false,
    condition: ListingCondition.gebraucht,
    status: ListingStatus.active,
    city: 'Karlsruhe',
    postalCode: '76133',
    hasFMarking: false,
    ships: false,
    bumpedAt: DateTime(2026, 8, 30),
    sellerId: 's1',
    categorySlug: 'langwaffen',
  );

  setUp(() {
    repository = MockListingRepository();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [listingRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('laedt Seite 1 mit dem festen Seitenlimit ab Offset 0', () async {
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 50));

    final container = buildContainer();
    final state = await container.read(listingFeedProvider(filter).future);

    expect(state.items, [summary('l1')]);
    expect(state.total, 50);
    expect(state.isLoadingMore, isFalse);
  });

  test('loadMore haengt Seite 2 an (Offset = aktuelle Laenge)', () async {
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 2));
    when(
      () => repository.search(filter, offset: 1),
    ).thenAnswer((_) async => (items: [summary('l2')], total: 2));

    final container = buildContainer();
    await container.read(listingFeedProvider(filter).future);

    await container.read(listingFeedProvider(filter).notifier).loadMore();

    final state = container.read(listingFeedProvider(filter)).value!;
    expect(state.items, [summary('l1'), summary('l2')]);
    expect(state.total, 2);
    expect(state.isLoadingMore, isFalse);
  });

  test('loadMore tut nichts, wenn total schon erreicht ist', () async {
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 1));

    final container = buildContainer();
    await container.read(listingFeedProvider(filter).future);

    await container.read(listingFeedProvider(filter).notifier).loadMore();

    final state = container.read(listingFeedProvider(filter)).value!;
    expect(state.items, [summary('l1')]);
    verifyNever(
      () => repository.search(filter, offset: 1),
    );
  });

  test('refresh laedt Seite 1 neu und ersetzt die Liste', () async {
    var callCount = 0;
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async {
      callCount++;
      return callCount == 1
          ? (items: [summary('l1')], total: 1)
          : (items: [summary('l2')], total: 1);
    });

    final container = buildContainer();
    await container.read(listingFeedProvider(filter).future);
    expect(container.read(listingFeedProvider(filter)).value!.items, [
      summary('l1'),
    ]);

    await container.read(listingFeedProvider(filter).notifier).refresh();

    final state = container.read(listingFeedProvider(filter)).value!;
    expect(state.items, [summary('l2')]);
  });

  test('ein Fehler in loadMore wirft die bestehende Liste nicht weg', () async {
    when(
      () => repository.search(filter),
    ).thenAnswer((_) async => (items: [summary('l1')], total: 5));
    when(
      () => repository.search(filter, offset: 1),
    ).thenThrow(const NetworkException());

    final container = buildContainer();
    await container.read(listingFeedProvider(filter).future);

    await container.read(listingFeedProvider(filter).notifier).loadMore();

    final state = container.read(listingFeedProvider(filter)).value!;
    expect(state.items, [summary('l1')]);
    expect(state.isLoadingMore, isFalse);
  });
}
