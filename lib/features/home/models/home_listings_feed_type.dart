/// Paginated home feed destinations opened from «عرض الكل».
enum HomeListingsFeedType {
  featured,
  latest;

  String get slug => switch (this) {
        featured => 'featured',
        latest => 'latest',
      };

  String get titleAr => switch (this) {
        featured => 'إعلانات مميزة',
        latest => 'أحدث الإعلانات',
      };

  static HomeListingsFeedType? fromSlug(String slug) => switch (slug) {
        'featured' => featured,
        'latest' => latest,
        _ => null,
      };
}
