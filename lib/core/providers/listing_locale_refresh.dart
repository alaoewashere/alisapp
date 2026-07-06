import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/favorites/data/favorites_repository.dart';
import '../../features/home/models/home_listings_feed_type.dart';
import '../../features/home/providers/home_feed_provider.dart';
import '../../features/home/providers/home_provider.dart';
import '../../features/listings/providers/listing_detail_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../services/translation_service.dart';

/// Clears translation cache and invalidates listing data after a locale change.
void invalidateListingDataProviders(Ref ref) {
  TranslationService.clearCache();
  ref.invalidate(featuredListingsProvider);
  ref.invalidate(recentListingsProvider);
  ref.invalidate(latestHomeListingsProvider);
  ref.invalidate(categoryListingsProvider);
  ref.invalidate(favoritesProvider);
  ref.invalidate(listingDetailProvider);
  ref.invalidate(listingDetailByReferenceProvider);
  ref.invalidate(sellerOtherListingsProvider);
  ref.invalidate(sellerListingsPreviewProvider);
  invalidateMyListingsProviders(ref);
  for (final type in HomeListingsFeedType.values) {
    ref.invalidate(homeFeedProvider(type));
  }
}
