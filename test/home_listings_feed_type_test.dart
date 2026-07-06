import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/home/models/home_listings_feed_type.dart';
import 'package:Sello/l10n/app_localizations.dart';

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

    test('localizedTitle returns strings for each locale', () {
      final ar = lookupAppLocalizations(const Locale('ar'));
      final en = lookupAppLocalizations(const Locale('en'));

      expect(
        HomeListingsFeedType.featured.localizedTitle(ar),
        ar.featuredListingsTitle,
      );
      expect(
        HomeListingsFeedType.latest.localizedTitle(ar),
        ar.homeFeedLatestTitle,
      );
      expect(
        HomeListingsFeedType.featured.localizedTitle(en),
        en.featuredListingsTitle,
      );
      expect(
        HomeListingsFeedType.latest.localizedTitle(en),
        en.homeFeedLatestTitle,
      );
    });
  });
}
