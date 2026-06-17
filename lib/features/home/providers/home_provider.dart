import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../utils/home_listing_search.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../listings/data/categories_repository.dart';
import '../../listings/data/listings_repository.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoriesRepositoryProvider).fetchParentCategories();
});

final featuredListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getFeaturedListings(
        limit: 10,
        userIdForFavorites: userId,
      );
});

final recentListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getRecentListings(
        limit: 20,
        userIdForFavorites: userId,
      );
});

class HomeSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
  void clear() => state = '';
}

final homeSearchQueryProvider =
    NotifierProvider<HomeSearchQueryNotifier, String>(
  HomeSearchQueryNotifier.new,
);

final filteredHomeListingsProvider = Provider<List<ListingModel>>((ref) {
  final query = ref.watch(homeSearchQueryProvider);
  final listings = ref.watch(recentListingsProvider).value;
  if (listings == null) return const [];
  return filterHomeListingsByTitle(listings, query);
});

final isHomeSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(homeSearchQueryProvider).trim().isNotEmpty;
});

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void select(int? categoryId) => state = categoryId;
  void clear() => state = null;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
  SelectedCategoryNotifier.new,
);

final categoryListingsProvider =
    FutureProvider.family<List<ListingModel>, String>((ref, queryKey) async {
  final parts = queryKey.split('|');
  final categoryId = parts.first;
  final listingType = parts.length > 1 ? parts[1] : null;
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getListingsByCategory(
        categoryId,
        listingType: listingType,
        userIdForFavorites: userId,
      );
});

String categoryListingsQueryKey(String categoryId, {String? listingType}) {
  if (listingType == null || listingType.isEmpty) return categoryId;
  return '$categoryId|$listingType';
}

Future<void> refreshHomeProviders(WidgetRef ref) async {
  ref.invalidate(categoriesProvider);
  ref.invalidate(featuredListingsProvider);
  ref.invalidate(recentListingsProvider);
  ref.invalidate(favoritesIdsProvider);
}

Future<void> toggleListingFavorite(WidgetRef ref, ListingModel listing) async {
  await ref.read(toggleFavoriteProvider.notifier).toggle(listing.id);
}
