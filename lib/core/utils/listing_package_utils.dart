import '../../shared/models/listing_model.dart';

/// Expiry duration when a listing is created — 30 days for every package
/// tier, matching both the package selection screen's duration label and
/// approve_pending_purchase's server-side expires_at calculation.
DateTime calculateListingExpiry(ListingPackage package) {
  return DateTime.now().add(const Duration(days: 30));
}

/// Sort weight for package priority (higher = shown first).
int packageWeight(String? package) {
  switch (package) {
    case 'premium':
    case 'مميز':
    case 'featured':
      return 3;
    case 'pro':
    case 'برو':
      return 2;
    default:
      return 1;
  }
}

int packageWeightForListing(ListingModel listing) {
  if (listing.isPremiumListing) return 3;
  if (listing.isProListing) return 2;
  return 1;
}

/// Sort listings: premium first, then pro, then standard; newest within tier.
void sortListingsByPackagePriority(List<ListingModel> listings) {
  listings.sort((a, b) {
    final weightCompare =
        packageWeightForListing(b).compareTo(packageWeightForListing(a));
    if (weightCompare != 0) return weightCompare;
    return b.createdAt.compareTo(a.createdAt);
  });
}

/// Home «أحدث النشرات والمعروضات»: برو before مجاني, مميز excluded.
List<ListingModel> sortLatestHomeFeedListings(List<ListingModel> listings) {
  final filtered = listings.where((l) => !l.isPremiumListing).toList();
  sortListingsByPackagePriority(filtered);
  return filtered;
}

/// Paginated slice after [sortLatestHomeFeedListings].
List<ListingModel> sliceLatestHomeFeedPage(
  List<ListingModel> listings, {
  required int page,
  required int pageSize,
}) {
  return sortLatestHomeFeedListings(listings)
      .skip(page * pageSize)
      .take(pageSize)
      .toList();
}
