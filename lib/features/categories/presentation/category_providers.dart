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

final FutureProviderFamily<Category, String> categoryBySlugProvider =
    FutureProvider.family<Category, String>(
      (ref, slug) => ref.watch(categoryRepositoryProvider).bySlug(slug),
    );

final FutureProviderFamily<List<Category>, String> categoryChildrenProvider =
    FutureProvider.family<List<Category>, String>(
      (ref, parentSlug) =>
          ref.watch(categoryRepositoryProvider).children(parentSlug),
    );
