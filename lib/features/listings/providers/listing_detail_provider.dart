import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../../../services/rating_service.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import 'listings_provider.dart';

typedef SellerListingsKey = ({String sellerId, String excludeListingId});

final listingDetailProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(listingsRepositoryProvider);
  return repo.getListingById(
    listingId,
    userIdForFavorites: userId,
  );
});

final listingDetailByReferenceProvider =
    FutureProvider.family<ListingModel?, int>((ref, referenceNo) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(listingsRepositoryProvider);
  return repo.getListingByReferenceNo(
    referenceNo,
    userIdForFavorites: userId,
  );
});

final sellerOtherListingsProvider =
    FutureProvider.family<List<ListingModel>, SellerListingsKey>(
  (ref, key) async {
    return ref.watch(listingsRepositoryProvider).getSellerListings(
          key.sellerId,
          excludeId: key.excludeListingId,
          limit: 6,
        );
  },
);

final sellerListingsCountProvider =
    FutureProvider.family<int, String>((ref, sellerId) async {
  return ref
      .watch(listingsRepositoryProvider)
      .countSellerActiveListings(sellerId);
});

final listingDetailActionsProvider =
    NotifierProvider<ListingDetailActionsNotifier, AsyncValue<void>>(
  ListingDetailActionsNotifier.new,
);

class ListingDetailActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  /// Marks listing sold. Returns last buyer id when a conversation exists.
  Future<String?> markAsSold(String listingId) async {
    String? lastBuyerId;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(listingsRepositoryProvider);
      await repo.markAsSold(listingId);

      final listing = await repo.getListingById(listingId);
      if (listing != null) {
        final ratingService = ref.read(ratingServiceProvider);
        lastBuyerId = await ratingService.getLastBuyerId(
          listingId: listingId,
          sellerId: listing.userId,
        );
        if (lastBuyerId != null) {
          await ratingService.notifyBuyerToRate(
            buyerId: lastBuyerId!,
            listingId: listingId,
          );
        }
      }

      ref.invalidate(listingDetailProvider(listingId));
      ref.invalidate(recentListingsProvider);
      ref.invalidate(latestHomeListingsProvider);
      invalidateMyListingsProviders(ref);
    });
    return state.hasError ? null : lastBuyerId;
  }

  Future<void> deleteListing(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(listingsRepositoryProvider).softDeleteListing(listingId);
      ref.invalidate(recentListingsProvider);
      ref.invalidate(latestHomeListingsProvider);
      invalidateMyListingsProviders(ref);
      ref.invalidate(featuredListingsProvider);
    });
  }
}
