import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';

final categoriesRepositoryProvider = Provider<CategoriesRepository>((ref) {
  return CategoriesRepository(ref.watch(supabaseClientProvider));
});

class CategoriesRepository {
  CategoriesRepository(this._client);

  final dynamic _client;

  static const _pageSize = 1000;

  List<CategoryModel> _mapRows(dynamic data) {
    return sortCategories(
      (data as List)
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Loads every category row (PostgREST default cap is 1000).
  Future<List<CategoryModel>> fetchAll() async {
    final all = <CategoryModel>[];
    var from = 0;

    while (true) {
      final data = await _client
          .from('categories')
          .select()
          .order('display_order', ascending: true)
          .order('id', ascending: true)
          .range(from, from + _pageSize - 1);

      final batch = _mapRows(data);
      all.addAll(batch);
      if (batch.length < _pageSize) break;
      from += _pageSize;
    }

    return all;
  }

  /// Direct children of [parentId] (always queries DB — used for drill-down).
  Future<List<CategoryModel>> fetchChildren(int parentId) async {
    return getSubcategories(parentId);
  }

  Future<List<CategoryModel>> getSubcategories(int parentId) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('parent_id', parentId)
        .order('display_order', ascending: true)
        .order('id', ascending: true);
    return _mapRows(data);
  }

  Future<List<CategoryModel>> fetchParentCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .isFilter('parent_id', null)
        .order('display_order', ascending: true)
        .order('id', ascending: true);
    return _mapRows(data);
  }

  Future<CategoryModel?> fetchBySlug(String slug) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('slug', slug)
        .maybeSingle();
    if (data == null) return null;
    return CategoryModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CategoryModel?> fetchById(int id) async {
    final data = await _client
        .from('categories')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (data == null) return null;
    return CategoryModel.fromJson(data as Map<String, dynamic>);
  }

  /// Direct approved active listing counts keyed by category_id.
  Future<Map<int, int>> fetchListingCountsByCategory({String? listingType}) async {
    try {
      final data = listingType == null
          ? await _client.rpc('category_listing_counts')
          : await _client.rpc(
              'category_listing_counts',
              params: {'p_listing_type': listingType},
            );
      final counts = <int, int>{};
      for (final row in data as List) {
        final map = row as Map<String, dynamic>;
        counts[map['category_id'] as int] =
            (map['listing_count'] as num).toInt();
      }
      return counts;
    } catch (_) {
      return {};
    }
  }
}
