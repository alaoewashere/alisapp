/// Local PNG icons for مساعدة منزلية and subcategories (`assets/assistant/`).
abstract final class HomeHelpCategoryIcons {
  static const basePath = 'assets/assistant';

  static const Map<String, String> bySlug = {
    'home_help': '$basePath/main.png',
    'home_cleaning': '$basePath/تنظيف المنزل.png',
    'home_cooking': '$basePath/طبخ واعداد الطعام.png',
    'home_childcare': '$basePath/رعايه الاطفال.png',
    'home_eldercare': '$basePath/رعايع كبار السن والمرضى.png',
    'home_driver': '$basePath/driver.png',
    'home_gardening': '$basePath/gardens-pools.png',
    'home_maintenance': '$basePath/صيانه واصلاح منزلي.png',
    'home_moving': '$basePath/نقل الاثاث والعفش.png',
    'home_security': '$basePath/حراسه وامن.png',
    'home_laundry': '$basePath/غسيل وكي الملابس.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
