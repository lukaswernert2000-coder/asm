import 'package:asm/core/errors/app_exception.dart';
import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  late MockFavoriteRepository repository;

  setUp(() {
    repository = MockFavoriteRepository();
  });

  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [favoriteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('favoriteListingIdsProvider ruft myListingIds() auf', () async {
    when(() => repository.myListingIds()).thenAnswer((_) async => ['l1', 'l2']);

    final container = buildContainer();

    final result = await container.read(favoriteListingIdsProvider.future);

    expect(result, ['l1', 'l2']);
  });

  group('favoriteProvider (FavoriteNotifier)', () {
    test('laedt den Ausgangszustand ueber isFavorited()', () async {
      when(() => repository.isFavorited('l1')).thenAnswer((_) async => true);

      final container = buildContainer();

      final result = await container.read(favoriteProvider('l1').future);

      expect(result, isTrue);
    });

    test(
      'toggle() aktualisiert sofort optimistisch, dann ruft add() auf',
      () async {
        when(() => repository.isFavorited('l1')).thenAnswer((_) async => false);
        when(() => repository.add('l1')).thenAnswer((_) async {});

        final container = buildContainer();
        await container.read(favoriteProvider('l1').future);

        final toggleFuture = container
            .read(favoriteProvider('l1').notifier)
            .toggle();
        // Sofort nach dem Aufruf (vor dem Await) muss der Zustand schon
        // umgeschaltet sein -- das ist der optimistische Teil.
        expect(container.read(favoriteProvider('l1')).value, isTrue);

        await toggleFuture;
        expect(container.read(favoriteProvider('l1')).value, isTrue);
        verify(() => repository.add('l1')).called(1);
      },
    );

    test('toggle() ruft remove() auf, wenn aktuell favorisiert', () async {
      when(() => repository.isFavorited('l1')).thenAnswer((_) async => true);
      when(() => repository.remove('l1')).thenAnswer((_) async {});

      final container = buildContainer();
      await container.read(favoriteProvider('l1').future);

      await container.read(favoriteProvider('l1').notifier).toggle();

      expect(container.read(favoriteProvider('l1')).value, isFalse);
      verify(() => repository.remove('l1')).called(1);
    });

    test('Fehlerfall setzt den Zustand zurueck', () async {
      when(() => repository.isFavorited('l1')).thenAnswer((_) async => false);
      when(() => repository.add('l1')).thenThrow(const NetworkException());

      final container = buildContainer();
      await container.read(favoriteProvider('l1').future);

      await container.read(favoriteProvider('l1').notifier).toggle();

      expect(container.read(favoriteProvider('l1')).value, isFalse);
    });
  });
}
