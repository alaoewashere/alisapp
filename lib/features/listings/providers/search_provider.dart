import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/search_analytics.dart';
import '../../../shared/models/listing_model.dart';
import '../data/listings_repository.dart';

const _recentSearchesKey = 'recent_searches_v1';
const _maxRecentSearches = 10;

final searchQueryProvider =
    NotifierProvider<SearchQueryNotifier, String>(SearchQueryNotifier.new);

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void set(String value) => state = value;
  void clear() => state = '';
}

final debouncedSearchQueryProvider =
    NotifierProvider<DebouncedSearchQueryNotifier, String>(
  DebouncedSearchQueryNotifier.new,
);

class DebouncedSearchQueryNotifier extends Notifier<String> {
  Timer? _timer;

  @override
  String build() {
    ref.listen(searchQueryProvider, (prev, next) {
      _timer?.cancel();
      _timer = Timer(const Duration(milliseconds: 400), () {
        state = next;
      });
    });
    ref.onDispose(() => _timer?.cancel());
    return ref.read(searchQueryProvider);
  }
}

final filterProvider =
    NotifierProvider<FilterNotifier, FilterModel>(FilterNotifier.new);

class FilterNotifier extends Notifier<FilterModel> {
  @override
  FilterModel build() => const FilterModel();

  void updateFilter(String field, dynamic value) {
    state = switch (field) {
      'query' => state.copyWith(query: value as String?),
      'categoryId' => state.copyWith(
          categoryId: value as int?,
          clearSubcategory: value == null,
        ),
      'subcategoryId' => state.copyWith(subcategoryId: value as int?),
      'governorate' => state.copyWith(governorate: value as String?),
      'city' => state.copyWith(city: value as String?),
      'minPrice' => state.copyWith(minPrice: value as double?),
      'maxPrice' => state.copyWith(maxPrice: value as double?),
      'condition' => state.copyWith(condition: value as FilterCondition),
      'sortBy' => state.copyWith(sortBy: value as SearchSortBy),
      'isFeaturedOnly' => state.copyWith(isFeaturedOnly: value as bool),
      'isNegotiableOnly' => state.copyWith(isNegotiableOnly: value as bool),
      _ => state,
    };
  }

  void setFilter(FilterModel filter) => state = filter;

  void resetFilters() => state = const FilterModel();

  void resetField(String field) {
    state = switch (field) {
      'query' => state.copyWith(clearQuery: true),
      'categoryId' =>
        state.copyWith(clearCategory: true, clearSubcategory: true),
      'subcategoryId' => state.copyWith(clearSubcategory: true),
      'governorate' => state.copyWith(clearGovernorate: true),
      'city' => state.copyWith(clearCity: true),
      'minPrice' => state.copyWith(clearMinPrice: true),
      'maxPrice' => state.copyWith(clearMaxPrice: true),
      'condition' => state.copyWith(condition: FilterCondition.all),
      'isFeaturedOnly' => state.copyWith(isFeaturedOnly: false),
      'isNegotiableOnly' => state.copyWith(isNegotiableOnly: false),
      _ => state,
    };
  }
}

final filterDraftProvider =
    NotifierProvider.autoDispose<FilterDraftNotifier, FilterModel>(
  FilterDraftNotifier.new,
);

class FilterDraftNotifier extends Notifier<FilterModel> {
  @override
  FilterModel build() => ref.read(filterProvider);

  void updateDraft(FilterModel draft) => state = draft;

  void resetDraft() => state = const FilterModel();
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
  RecentSearchesNotifier.new,
);

class RecentSearchesNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    Future.microtask(_load);
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_recentSearchesKey) ?? [];
  }

  Future<void> addSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;
    final updated = [
      trimmed,
      ...state.where((s) => s != trimmed),
    ].take(_maxRecentSearches).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, updated);
  }

  Future<void> removeSearch(String query) async {
    state = state.where((s) => s != query).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, state);
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
  }
}

final searchSuggestionsProvider =
    FutureProvider.family<List<String>, String>((ref, query) async {
  if (query.trim().length < 2) return [];

  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (query != ref.read(debouncedSearchQueryProvider)) return [];

  final dbSuggestions =
      await ref.read(listingsRepositoryProvider).getSearchSuggestions(query);
  final recent = ref.read(recentSearchesProvider);
  final merged = <String>[];
  for (final r in recent.where((s) => s.contains(query))) {
    if (merged.length >= 8) break;
    merged.add(r);
  }
  for (final s in dbSuggestions) {
    if (merged.length >= 8) break;
    if (!merged.contains(s)) merged.add(s);
  }
  return merged;
});

final filterPreviewCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final draft = ref.watch(filterDraftProvider);
  await Future<void>.delayed(const Duration(milliseconds: 600));
  return ref.read(listingsRepositoryProvider).countSearchResults(draft);
});

class SearchResultsState {
  const SearchResultsState({
    this.items = const [],
    this.totalCount = 0,
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<ListingModel> items;
  final int totalCount;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  SearchResultsState copyWith({
    List<ListingModel>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return SearchResultsState(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final searchResultsProvider =
    NotifierProvider<SearchResultsNotifier, SearchResultsState>(
  SearchResultsNotifier.new,
);

class SearchResultsNotifier extends Notifier<SearchResultsState> {
  FilterModel _filter = const FilterModel();

  @override
  SearchResultsState build() => const SearchResultsState();

  FilterModel get currentFilter => _filter;

  Future<void> search(FilterModel filter, {bool log = true}) async {
    _filter = filter;
    state = state.copyWith(isLoading: true, clearError: true, page: 0);

    try {
      final userId = ref.read(currentUserIdProvider);
      final repo = ref.read(listingsRepositoryProvider);
      final total = await repo.countSearchResults(filter);
      final items = await repo.searchListings(
        filter,
        page: 0,
        userIdForFavorites: userId,
      );

      if (log && (filter.query?.trim().isNotEmpty ?? false)) {
        logSearch(
          client: ref.read(supabaseClientProvider),
          userId: userId,
          query: filter.query!,
          resultsCount: total,
        );
        await ref
            .read(recentSearchesProvider.notifier)
            .addSearch(filter.query!);
      }

      state = SearchResultsState(
        items: items,
        totalCount: total,
        page: 0,
        hasMore: items.length >= 20,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final nextPage = state.page + 1;
      final items = await ref.read(listingsRepositoryProvider).searchListings(
            _filter,
            page: nextPage,
            userIdForFavorites: userId,
          );

      final existingIds = state.items.map((e) => e.id).toSet();
      final merged = [
        ...state.items,
        ...items.where((e) => !existingIds.contains(e.id)),
      ];

      state = state.copyWith(
        items: merged,
        page: nextPage,
        hasMore: items.length >= 20,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<void> refresh() => search(_filter, log: false);
}

final searchViewModeProvider =
    NotifierProvider<SearchViewModeNotifier, bool>(SearchViewModeNotifier.new);

/// true = grid, false = list
class SearchViewModeNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void toggle() => state = !state;
  void setGrid(bool grid) => state = grid;
}

String filterCacheKey(FilterModel filter) => jsonEncode(filter.toJson());
