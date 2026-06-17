import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
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
    ref.watch(currentUserIdProvider);

    ref.listen(favoritesIdsProvider, (previous, next) {
      next.whenData((ids) => state = Set<String>.from(ids));
    }, fireImmediately: true);

    final asyncIds = ref.watch(favoritesIdsProvider);
    return asyncIds.when(
      data: (ids) => Set<String>.from(ids),
      loading: () =>
          asyncIds.hasValue ? Set<String>.from(asyncIds.requireValue) : {},
      error: (_, __) =>
          asyncIds.hasValue ? Set<String>.from(asyncIds.requireValue) : {},
    );
  }

  Future<void> toggle(String listingId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final wasFavorite = state.contains(listingId);

    try {
      if (wasFavorite) {
        await ref.read(favoritesRepositoryProvider).removeFavorite(
              userId,
              listingId,
            );
        state = Set<String>.from(state)..remove(listingId);
      } else {
        await ref.read(favoritesRepositoryProvider).addFavorite(
              userId,
              listingId,
            );
        state = {...state, listingId};
      }
      ref.invalidate(favoritesProvider);
    } catch (_) {
      // Keep prior state on failure — do not optimistically flip UI.
    }
  }

  bool isFavorite(String listingId) => state.contains(listingId);
}

final toggleFavoriteProvider =
    NotifierProvider<FavoriteToggleNotifier, Set<String>>(
  FavoriteToggleNotifier.new,
);
