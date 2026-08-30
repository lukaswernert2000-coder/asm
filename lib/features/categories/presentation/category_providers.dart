import 'package:asm/core/supabase/supabase_provider.dart';
import 'package:asm/features/categories/data/category_repository.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryRepositoryProvider = Provider<CategoryRepository>(
  (ref) => SupabaseCategoryRepository(ref.watch(supabaseProvider)),
);

final rootCategoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).roots(),
);

final allCategoriesProvider = FutureProvider<List<Category>>(
  (ref) => ref.watch(categoryRepositoryProvider).all(),
);

final FutureProviderFamily<Category, String> categoryBySlugProvider =
    FutureProvider.family<Category, String>(
      (ref, slug) => ref.watch(categoryRepositoryProvider).bySlug(slug),
    );

/// Leitet sich aus [allCategoriesProvider] ab statt eines eigenen Requests
/// -- der Kategoriebaum ist komplett und klein, kein `byId()` auf dem
/// Repository noetig. Fuer Task 4.2, wo nur die `categoryId` bekannt ist.
final FutureProviderFamily<Category?, String> categoryByIdProvider =
    FutureProvider.family<Category?, String>((ref, id) async {
      final all = await ref.watch(allCategoriesProvider.future);
      for (final category in all) {
        if (category.id == id) return category;
      }
      return null;
    });

final FutureProviderFamily<List<Category>, String> categoryChildrenProvider =
    FutureProvider.family<List<Category>, String>(
      (ref, parentSlug) =>
          ref.watch(categoryRepositoryProvider).children(parentSlug),
    );
