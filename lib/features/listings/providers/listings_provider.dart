import 'package:flutter_riverpod/flutter_riverpod.dart';

export '../data/listings_repository.dart';

class ListingFavoriteLoadingNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setListingId(String? id) => state = id;
}

final listingFavoriteLoadingProvider =
    NotifierProvider<ListingFavoriteLoadingNotifier, String?>(
  ListingFavoriteLoadingNotifier.new,
);
