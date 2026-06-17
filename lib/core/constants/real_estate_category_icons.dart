/// Local PNG icons for العقارات and its subcategories (`assets/real-estate-icons/`).
abstract final class RealEstateCategoryIcons {
  static const basePath = 'assets/real-estate-icons';

  static const Map<String, String> bySlug = {
    'real_estate': '$basePath/real-estate.png',
    're_residential': '$basePath/سكني.png',
    're_tourism': '$basePath/منشات سياحيه.png',
    're_shared': '$basePath/ملكيه مشتركة.png',
    're_land': '$basePath/اراضي.png',
    're_projects': '$basePath/مشاريع سكنيه.png',
    're_commercial': '$basePath/محلات تجاريه.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
