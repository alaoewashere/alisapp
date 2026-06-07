import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../data/listings_repository.dart';

export '../data/listings_repository.dart';

// Legacy alias — prefer myListingsProvider(status) from profile_provider.
final legacyMyListingsProvider = FutureProvider<List<ListingModel>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref.watch(listingsRepositoryProvider).fetchMyListings(userId);
});

class ListingFavoriteLoadingNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setListingId(String? id) => state = id;
}

final listingFavoriteLoadingProvider =
    NotifierProvider<ListingFavoriteLoadingNotifier, String?>(
  ListingFavoriteLoadingNotifier.new,
);
