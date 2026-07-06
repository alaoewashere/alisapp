import '../../../l10n/app_localizations.dart';

/// Paginated home feed destinations opened from «عرض الكل».
enum HomeListingsFeedType {
  featured,
  latest;

  String get slug => switch (this) {
        featured => 'featured',
        latest => 'latest',
      };

  String localizedTitle(AppLocalizations strings) => switch (this) {
        featured => strings.featuredListingsTitle,
        latest => strings.homeFeedLatestTitle,
      };

  static HomeListingsFeedType? fromSlug(String slug) => switch (slug) {
        'featured' => featured,
        'latest' => latest,
        _ => null,
      };
}
