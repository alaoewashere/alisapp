import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../utils/home_listing_search.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../listings/data/categories_repository.dart';
import '../../listings/data/listings_repository.dart';
import '../../notifications/providers/notifications_provider.dart';

final categoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoriesRepositoryProvider).fetchParentCategories();
});

final featuredListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  ref.watch(localeProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getFeaturedListings(
        limit: 10,
        userIdForFavorites: userId,
      );
});

final recentListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  ref.watch(localeProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getRecentListings(
        limit: 20,
        userIdForFavorites: userId,
      );
});

/// Home «أحدث النشرات والمعروضات» — برو + مجاني, package priority then newest.
final latestHomeListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  ref.watch(localeProvider);
  final userId = ref.watch(currentUserIdProvider);
  return ref.watch(listingsRepositoryProvider).getLatestHomeListings(
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
  final listings = ref.watch(latestHomeListingsProvider).value;
  if (listings == null) return const [];
  return filterHomeListingsByTitle(listings, query);
});

final isHomeSearchActiveProvider = Provider<bool>((ref) {
  return ref.watch(homeSearchQueryProvider).trim().isNotEmpty;
});

class SelectedCategoryNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  /// Tapping the active category again clears it (toggle).
  void toggle(int categoryId) =>
      state = state == categoryId ? null : categoryId;
  void select(int? categoryId) => state = categoryId;
  void clear() => state = null;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, int?>(
  SelectedCategoryNotifier.new,
);

/// Package-tier filter for the home feed.
enum HomeTierFilter { premium, pro, standard }

class HomeTierFilterNotifier extends Notifier<HomeTierFilter?> {
  @override
  HomeTierFilter? build() => null;

  void toggle(HomeTierFilter tier) => state = state == tier ? null : tier;
  void clear() => state = null;
}

final homeTierFilterProvider =
    NotifierProvider<HomeTierFilterNotifier, HomeTierFilter?>(
  HomeTierFilterNotifier.new,
);

/// True when the home feed is being filtered by a category and/or tier.
final homeFilterActiveProvider = Provider<bool>((ref) {
  return ref.watch(selectedCategoryProvider) != null ||
      ref.watch(homeTierFilterProvider) != null;
});

/// Lightweight `{id: parentId}` map to resolve a listing's root category.
final categoryParentMapProvider = FutureProvider<Map<int, int?>>((ref) async {
  return ref.watch(categoriesRepositoryProvider).fetchParentMap();
});

/// Walks up [parentMap] to find the top-level (root) ancestor of [categoryId].
int rootCategoryIdFor(int categoryId, Map<int, int?> parentMap) {
  var current = categoryId;
  // Guard against cycles / missing rows with a hard cap.
  for (var i = 0; i < 32; i++) {
    final parent = parentMap[current];
    if (parent == null) break;
    current = parent;
  }
  return current;
}

/// Home feed filtered in-place by the selected category subtree and/or tier.
/// Pulls from the already-loaded featured + latest pools (no extra round-trip).
final homeFilteredFeedProvider = Provider<List<ListingModel>>((ref) {
  final selectedCategory = ref.watch(selectedCategoryProvider);
  final tier = ref.watch(homeTierFilterProvider);
  final featured = ref.watch(featuredListingsProvider).value ?? const [];
  final latest = ref.watch(latestHomeListingsProvider).value ?? const [];
  final parentMap = ref.watch(categoryParentMapProvider).value;

  // Merge featured + latest, de-duplicated by id (featured first).
  final seen = <String>{};
  final pool = <ListingModel>[];
  for (final listing in [...featured, ...latest]) {
    if (seen.add(listing.id)) pool.add(listing);
  }

  Iterable<ListingModel> result = pool;

  if (selectedCategory != null && parentMap != null) {
    result = result.where(
      (l) => rootCategoryIdFor(l.categoryId, parentMap) == selectedCategory,
    );
  }

  if (tier != null) {
    result = result.where((l) => switch (tier) {
          HomeTierFilter.premium => l.isPremiumListing,
          HomeTierFilter.pro => l.isProListing,
          HomeTierFilter.standard => l.isStandardListing,
        });
  }

  return result.toList();
});

final categoryListingsProvider =
    FutureProvider.family<List<ListingModel>, String>((ref, queryKey) async {
  ref.watch(localeProvider);
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
  ref.invalidate(latestHomeListingsProvider);
  ref.invalidate(recentListingsProvider);
  ref.invalidate(favoritesIdsProvider);
  ref.invalidate(notificationsProvider);
}

Future<void> toggleListingFavorite(WidgetRef ref, ListingModel listing) async {
  await ref.read(toggleFavoriteProvider.notifier).toggle(listing.id);
}
