import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../../listings/data/listings_repository.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepository(ref.watch(supabaseClientProvider));
});

class FavoritesRepository {
  FavoritesRepository(this._client);

  final dynamic _client;

  Future<List<ListingModel>> getFavorites(String userId) async {
    return fetchFavorites(userId);
  }

  Future<List<ListingModel>> fetchFavorites(String userId) async {
    final data = await _client
        .from('favorites')
        .select('''
          listing_id,
          listings(
            *,
            categories(name_ar),
            profiles!listings_user_id_fkey(display_name),
            listing_images(id, listing_id, storage_path, sort_order)
          )
        ''')
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    final listings = <Map<String, dynamic>>[];
    for (final row in data as List) {
      final listing = row['listings'] as Map<String, dynamic>?;
      if (listing != null && listing['status'] == 'approved') {
        listing['is_favorite'] = true;
        listings.add(listing);
      }
    }

    final repo = ListingsRepository(_client);
    return _mapFavoriteListings(listings, repo);
  }

  Future<Set<String>> getFavoriteIds(String userId) async {
    final data = await _client
        .from('favorites')
        .select('listing_id')
        .eq('user_id', userId);
    return (data as List)
        .map((row) => (row as Map<String, dynamic>)['listing_id'] as String)
        .toSet();
  }

  Future<List<ListingModel>> _mapFavoriteListings(
    List<Map<String, dynamic>> raw,
    ListingsRepository repo,
  ) async {
    return raw.map((map) {
      final images = (map['listing_images'] as List?) ?? [];
      if (images.isNotEmpty) {
        images.sort(
          (a, b) => (a['sort_order'] as int).compareTo(b['sort_order'] as int),
        );
        map['cover_image_url'] =
            repo.publicUrlForPath(images.first['storage_path'] as String);
        map['listing_images'] = images.map((img) {
          final imgMap = Map<String, dynamic>.from(img as Map);
          imgMap['storage_path'] =
              repo.publicUrlForPath(imgMap['storage_path'] as String);
          return imgMap;
        }).toList();
      }
      map['is_favorite'] = true;
      return ListingModel.fromJson(map);
    }).toList();
  }

  Future<void> addFavorite(String userId, String listingId) async {
    await _client.from('favorites').insert({
      'user_id': userId,
      'listing_id': listingId,
    });
  }

  Future<void> removeFavorite(String userId, String listingId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('listing_id', listingId);
  }

  Future<bool> toggle(String userId, String listingId) async {
    final existing = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('listing_id', listingId)
        .maybeSingle();

    if (existing != null) {
      await removeFavorite(userId, listingId);
      return false;
    }

    await addFavorite(userId, listingId);
    return true;
  }

  Future<bool> isFavorite(String userId, String listingId) async {
    final data = await _client
        .from('favorites')
        .select()
        .eq('user_id', userId)
        .eq('listing_id', listingId)
        .maybeSingle();
    return data != null;
  }
}

final favoritesProvider = FutureProvider<List<ListingModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(favoritesRepositoryProvider).getFavorites(userId);
});
