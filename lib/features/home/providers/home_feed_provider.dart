import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../../listings/data/listings_repository.dart';
import '../models/home_listings_feed_type.dart';

class HomeFeedState {
  const HomeFeedState({
    this.items = const [],
    this.page = 0,
    this.hasMore = true,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  final List<ListingModel> items;
  final int page;
  final bool hasMore;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  HomeFeedState copyWith({
    List<ListingModel>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) {
    return HomeFeedState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

final homeFeedProvider = NotifierProvider.autoDispose
    .family<HomeFeedNotifier, HomeFeedState, HomeListingsFeedType>(
  HomeFeedNotifier.new,
);

class HomeFeedNotifier extends Notifier<HomeFeedState> {
  HomeFeedNotifier(this.feedType);

  final HomeListingsFeedType feedType;

  @override
  HomeFeedState build() {
    Future.microtask(loadInitial);
    return const HomeFeedState(isLoading: true);
  }

  Future<void> loadInitial() async {
    state = const HomeFeedState(isLoading: true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final repo = ref.read(listingsRepositoryProvider);
      final items = await _fetchPage(repo, userId, page: 0);
      state = HomeFeedState(
        items: items,
        page: 0,
        hasMore: items.length >= AppConstants.listingsPageSize,
        isLoading: false,
      );
    } catch (e) {
      state = HomeFeedState(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => loadInitial();

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    try {
      final userId = ref.read(currentUserIdProvider);
      final repo = ref.read(listingsRepositoryProvider);
      final nextPage = state.page + 1;
      final items = await _fetchPage(repo, userId, page: nextPage);

      final existingIds = state.items.map((e) => e.id).toSet();
      final merged = [
        ...state.items,
        ...items.where((e) => !existingIds.contains(e.id)),
      ];

      state = state.copyWith(
        items: merged,
        page: nextPage,
        hasMore: items.length >= AppConstants.listingsPageSize,
        isLoadingMore: false,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }

  Future<List<ListingModel>> _fetchPage(
    ListingsRepository repo,
    String? userId, {
    required int page,
  }) {
    return switch (feedType) {
      HomeListingsFeedType.featured => repo.getFeaturedListingsPage(
          page: page,
          userIdForFavorites: userId,
        ),
      HomeListingsFeedType.latest => repo.getLatestHomeListingsPage(
          page: page,
          userIdForFavorites: userId,
        ),
    };
  }
}
