import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import 'listings_provider.dart';

typedef SellerListingsKey = ({String sellerId, String excludeListingId});

final listingDetailProvider =
    FutureProvider.family<ListingModel?, String>((ref, listingId) async {
  final userId = ref.watch(currentUserIdProvider);
  final repo = ref.watch(listingsRepositoryProvider);
  final listing = await repo.getListingById(
    listingId,
    userIdForFavorites: userId,
  );
  if (listing != null) {
    repo.incrementViews(listingId);
  }
  return listing;
});

final isOwnerProvider = Provider.family<bool, String>((ref, listingId) {
  final listing = ref.watch(listingDetailProvider(listingId)).value;
  final userId = ref.watch(currentUserIdProvider);
  if (listing == null || userId == null) return false;
  return listing.userId == userId;
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

/// Local UI toggle for description expand on detail screen.
final descriptionExpandedProvider =
    NotifierProvider.family<DescriptionExpandedNotifier, bool, String>(
  DescriptionExpandedNotifier.new,
);

class DescriptionExpandedNotifier extends Notifier<bool> {
  DescriptionExpandedNotifier(this.listingId);

  final String listingId;

  @override
  bool build() => false;

  void toggle() => state = !state;
}

final listingDetailActionsProvider =
    NotifierProvider<ListingDetailActionsNotifier, AsyncValue<void>>(
  ListingDetailActionsNotifier.new,
);

class ListingDetailActionsNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> markAsSold(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(listingsRepositoryProvider).markAsSold(listingId);
      ref.invalidate(listingDetailProvider(listingId));
      ref.invalidate(recentListingsProvider);
      invalidateMyListingsProviders(ref);
    });
  }

  Future<void> deleteListing(String listingId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(listingsRepositoryProvider).softDeleteListing(listingId);
      ref.invalidate(recentListingsProvider);
      invalidateMyListingsProviders(ref);
      ref.invalidate(featuredListingsProvider);
    });
  }
}
