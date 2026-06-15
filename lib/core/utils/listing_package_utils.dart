import '../../shared/models/listing_model.dart';

/// Expiry duration when a listing is created, by package tier.
DateTime calculateListingExpiry(ListingPackage package) {
  final now = DateTime.now();
  return switch (package) {
    ListingPackage.premium => now.add(const Duration(days: 35)),
    ListingPackage.pro => now.add(const Duration(days: 25)),
    ListingPackage.standard => now.add(const Duration(days: 20)),
  };
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
