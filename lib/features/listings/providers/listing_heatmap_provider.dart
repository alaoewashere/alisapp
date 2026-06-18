import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/listings_repository.dart';
import '../models/listing_density.dart';

final heatmapCategorySlugProvider =
    NotifierProvider<HeatmapCategorySlugNotifier, String?>(
  HeatmapCategorySlugNotifier.new,
);

class HeatmapCategorySlugNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String? slug) => state = slug;
}

final listingDensityProvider =
    FutureProvider.autoDispose<List<ListingDensity>>((ref) async {
  final slug = ref.watch(heatmapCategorySlugProvider);
  return ref.read(listingsRepositoryProvider).getListingDensity(
        categorySlug: slug,
      );
});
