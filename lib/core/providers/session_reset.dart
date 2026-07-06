import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/favorites/providers/favorites_provider.dart';
import '../../features/home/providers/home_provider.dart';
import '../../features/listings/providers/search_provider.dart';
import '../../features/profile/providers/profile_provider.dart';

/// Clears user-scoped cached state after logout or account deletion.
///
/// Accepts a [ProviderContainer] so callers can pass [WidgetRef.container]
/// before an async gap (e.g. [signOut]) that may unmount the widget.
void invalidateSessionProviders(ProviderContainer container) {
  container.invalidate(currentProfileProvider);
  container.invalidate(myProfileProvider);
  container.invalidate(favoritesProvider);
  container.invalidate(favoritesIdsProvider);
  container.invalidate(myListingsCountsProvider);
  for (final status in ['active', 'pending', 'sold', 'deleted']) {
    container.invalidate(myListingsProvider(status));
  }
  container.invalidate(recentSearchesProvider);
  container.invalidate(featuredListingsProvider);
  container.invalidate(recentListingsProvider);
  container.invalidate(latestHomeListingsProvider);
}
