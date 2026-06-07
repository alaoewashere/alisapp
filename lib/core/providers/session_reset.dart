import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/home/providers/home_provider.dart';
import '../../features/listings/providers/search_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

/// Clears user-scoped cached state after logout or account deletion.
void invalidateSessionProviders(Ref ref) {
  ref.invalidate(currentProfileProvider);
  ref.invalidate(myProfileProvider);
  ref.invalidate(favoritesProvider);
  ref.invalidate(favoritesIdsProvider);
  ref.invalidate(myListingsCountsProvider);
  for (final status in ['active', 'pending', 'sold', 'deleted']) {
    ref.invalidate(myListingsProvider(status));
  }
  ref.invalidate(recentSearchesProvider);
  ref.invalidate(featuredListingsProvider);
  ref.invalidate(recentListingsProvider);
}
