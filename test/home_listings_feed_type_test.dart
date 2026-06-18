import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/home/models/home_listings_feed_type.dart';

void main() {
  group('HomeListingsFeedType', () {
    test('fromSlug resolves known slugs', () {
      expect(
        HomeListingsFeedType.fromSlug('featured'),
        HomeListingsFeedType.featured,
      );
      expect(
        HomeListingsFeedType.fromSlug('latest'),
        HomeListingsFeedType.latest,
      );
      expect(HomeListingsFeedType.fromSlug('unknown'), isNull);
    });

    test('slug round-trips', () {
      for (final type in HomeListingsFeedType.values) {
        expect(HomeListingsFeedType.fromSlug(type.slug), type);
      }
    });

    test('titles are Arabic', () {
      expect(HomeListingsFeedType.featured.titleAr, 'إعلانات مميزة');
      expect(HomeListingsFeedType.latest.titleAr, 'أحدث الإعلانات');
    });
  });
}
