import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/supabase/supabase_client.dart';
import 'package:Sello/features/favorites/data/favorites_repository.dart';
import 'package:Sello/features/favorites/providers/favorites_provider.dart';

class _FakeFavoritesRepository extends FavoritesRepository {
  _FakeFavoritesRepository(Set<String> ids) : super(null) {
    _ids = Set<String>.from(ids);
  }

  Set<String> _ids = {};
  bool addCalled = false;
  bool removeCalled = false;

  @override
  Future<Set<String>> getFavoriteIds(String userId) async => _ids;

  @override
  Future<void> addFavorite(String userId, String listingId) async {
    addCalled = true;
    _ids = {..._ids, listingId};
  }

  @override
  Future<void> removeFavorite(String userId, String listingId) async {
    removeCalled = true;
    _ids = _ids.where((id) => id != listingId).toSet();
  }
}

void main() {
  test('FavoriteToggleNotifier loads ids from favoritesIdsProvider', () async {
    final fakeRepo = _FakeFavoritesRepository({'listing-a'});
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('user-1'),
        favoritesRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    await container.read(favoritesIdsProvider.future);
    final ids = container.read(toggleFavoriteProvider);
    expect(ids, {'listing-a'});

    container.dispose();
  });

  test('FavoriteToggleNotifier toggles after DB write', () async {
    final fakeRepo = _FakeFavoritesRepository({'listing-a'});
    final container = ProviderContainer(
      overrides: [
        currentUserIdProvider.overrideWithValue('user-1'),
        favoritesRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );

    await container.read(favoritesIdsProvider.future);
    await container
        .read(toggleFavoriteProvider.notifier)
        .toggle('listing-b');

    expect(fakeRepo.addCalled, isTrue);
    expect(container.read(toggleFavoriteProvider), {'listing-a', 'listing-b'});

    container.dispose();
  });
}
