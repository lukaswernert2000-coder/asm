import 'package:asm/features/favorites/data/favorite_repository.dart';
import 'package:asm/features/favorites/presentation/favorite_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFavoriteRepository extends Mock implements FavoriteRepository {}

void main() {
  test('isFavoritedProvider ruft isFavorited() mit der ID auf', () async {
    final repository = MockFavoriteRepository();
    when(() => repository.isFavorited('l1')).thenAnswer((_) async => true);

    final container = ProviderContainer(
      overrides: [favoriteRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final result = await container.read(isFavoritedProvider('l1').future);

    expect(result, isTrue);
  });

  // toggleFavorite() nimmt ein WidgetRef (gleiches Muster wie
  // setListingViewMode) -- ueber den echten Herz-Button auf der Detailseite
  // getestet, nicht isoliert mit einem konstruierten Ref.
}
