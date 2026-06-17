/// Local PNG icons for الحيوانات and subcategories (`assets/animals-icons/`).
abstract final class PetsCategoryIcons {
  static const basePath = 'assets/animals-icons';

  static const Map<String, String> bySlug = {
    'pets': '$basePath/main.png',
    'pets_dogs': '$basePath/كلاب.png',
    'pets_cats': '$basePath/قطط.png',
    'pets_birds': '$basePath/طيور.png',
    'pets_fish': '$basePath/اسماك واحواض.png',
    'pets_farm': '$basePath/حيوانات المزرعه.png',
    'pets_reptiles': '$basePath/reptiles.png',
    'pets_rabbits': '$basePath/ارانب وقوارض.png',
    'pets_accessories': '$basePath/مستلزمات الحيوانات.png',
    'pets_services': '$basePath/خدمات الحيوانات.png',
    'pets_lost_found': '$basePath/مفقود وموجود.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
