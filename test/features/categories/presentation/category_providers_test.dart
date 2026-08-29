import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:asm/features/categories/presentation/category_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCategoryRepository extends Mock implements CategoryRepository {}

void main() {
  late MockCategoryRepository repository;
  late ProviderContainer container;

  const category = Category(
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
  );

  setUp(() {
    repository = MockCategoryRepository();
    container = ProviderContainer(
      overrides: [categoryRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);
  });

  test('categoryBySlugProvider ruft bySlug() mit dem Slug auf', () async {
    when(
      () => repository.bySlug('langwaffen'),
    ).thenAnswer((_) async => category);

    final result = await container.read(
      categoryBySlugProvider('langwaffen').future,
    );

    expect(result, category);
  });

  test(
    'categoryChildrenProvider ruft children() mit dem Eltern-Slug auf',
    () async {
      when(
        () => repository.children('langwaffen'),
      ).thenAnswer((_) async => [category]);

      final result = await container.read(
        categoryChildrenProvider('langwaffen').future,
      );

      expect(result, [category]);
    },
  );
}
