/// Default category tile icon for levels without a dedicated PNG (except المركبات/العقارات).
abstract final class CategoryFallbackIcon {
  static const assetPath =
      'assets/Navigation-Menu-Horizontal--Streamline-Ultimate.png';

  /// Slugs under المركبات or العقارات keep emoji / brand logos when unmapped.
  static bool isExcludedTreeSlug(String slug) {
    return slug == 'cars' ||
        slug == 'real_estate' ||
        slug.startsWith('veh_') ||
        slug.startsWith('re_');
  }

  static String? assetForSlug(String slug) {
    if (isExcludedTreeSlug(slug)) return null;
    return assetPath;
  }
}
