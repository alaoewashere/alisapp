import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../home/providers/home_provider.dart';
import '../data/favorites_repository.dart';

export '../data/favorites_repository.dart';

final favoritesIdsProvider = FutureProvider<Set<String>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return {};
  return ref.watch(favoritesRepositoryProvider).getFavoriteIds(userId);
});

class FavoriteToggleNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final asyncIds = ref.watch(favoritesIdsProvider);
    return asyncIds.maybeWhen(data: (ids) => ids, orElse: () => {});
  }

  Future<void> toggle(String listingId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final wasFavorite = state.contains(listingId);
    state = wasFavorite
        ? (Set<String>.from(state)..remove(listingId))
        : {...state, listingId};

    try {
      if (wasFavorite) {
        await ref.read(favoritesRepositoryProvider).removeFavorite(
              userId,
              listingId,
            );
      } else {
        await ref.read(favoritesRepositoryProvider).addFavorite(
              userId,
              listingId,
            );
      }
      ref.invalidate(favoritesProvider);
      ref.invalidate(favoritesIdsProvider);
      ref.invalidate(recentListingsProvider);
      ref.invalidate(featuredListingsProvider);
    } catch (_) {
      state = wasFavorite
          ? {...state, listingId}
          : (Set<String>.from(state)..remove(listingId));
    }
  }

  bool isFavorite(String listingId) => state.contains(listingId);
}

final toggleFavoriteProvider =
    NotifierProvider<FavoriteToggleNotifier, Set<String>>(
  FavoriteToggleNotifier.new,
);
