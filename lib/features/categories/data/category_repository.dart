import 'package:asm/core/errors/error_mapper.dart';
import 'package:asm/features/categories/domain/category.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract interface class CategoryRepository {
  Future<List<Category>> roots();
  Future<List<Category>> children(String parentSlug);
  Future<Category> bySlug(String slug);
}

class SupabaseCategoryRepository implements CategoryRepository {
  SupabaseCategoryRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Category>> roots() async {
    try {
      final rows = await _client
          .from('categories')
          .select()
          .filter('parent_id', 'is', null)
          .eq('is_active', true)
          .order('sort_order');
      return rows.map(Category.fromJson).toList();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<List<Category>> children(String parentSlug) async {
    try {
      final parent = await bySlug(parentSlug);
      final rows = await _client
          .from('categories')
          .select()
          .eq('parent_id', parent.id)
          .eq('is_active', true)
          .order('sort_order');
      return rows.map(Category.fromJson).toList();
    } catch (error) {
      throw mapError(error);
    }
  }

  @override
  Future<Category> bySlug(String slug) async {
    try {
      final row = await _client
          .from('categories')
          .select()
          .eq('slug', slug)
          .single();
      return Category.fromJson(row);
    } catch (error) {
      throw mapError(error);
    }
  }
}
