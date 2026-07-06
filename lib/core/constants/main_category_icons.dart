/// Root category tile icons (`assets/main_categories_icon/`).
abstract final class MainCategoryIcons {
  static const basePath = 'assets/main_categories_icon';

  static const Map<String, String> bySlug = {
    'real_estate': '$basePath/العقارات.png',
    'cars': '$basePath/المركبات.png',
    'electronics': '$basePath/الالكترونيات.png',
    'buy_sell': '$basePath/سوق المستعمل والجديد.png',
    'tutoring': '$basePath/دروس خصوصيه.png',
    'jobs': '$basePath/فرص عمل.png',
    'pets': '$basePath/الحيوانات.png',
    'home_help': '$basePath/مساعده منزليه.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);

  static bool isMainCategoryAsset(String assetPath) =>
      assetPath.startsWith('$basePath/');
}
