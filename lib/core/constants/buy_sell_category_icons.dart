/// Local PNG icons for سوق المستعمل والجديد and subcategories.
abstract final class BuySellCategoryIcons {
  static const basePath = 'assets/usedandnewmarketicons';

  static const Map<String, String> bySlug = {
    'buy_sell': '$basePath/main-for-used-and-new-market.png',
    'souq_mobile': '$basePath/موبايلات واكسسوارات.png',
    'souq_computer': '$basePath/كمبيوتر ولابتوب.png',
    'souq_tv_audio': '$basePath/شاشات وصوتيات.png',
    'souq_appliances': '$basePath/اجهزة المنزل الكهربائية.png',
    'souq_kitchen': '$basePath/اجهزه طبخ.png',
    'souq_gaming': '$basePath/العاب فيديو وترفيه.png',
    'souq_fashion': '$basePath/ملابس وازياء.png',
    'souq_beauty': '$basePath/صحه وجمال.png',
    'souq_furniture': '$basePath/اثاث ومفروشات.png',
    'souq_sports': '$basePath/رياضه ولياقه.png',
    'souq_baby': '$basePath/اطفال وامومه.png',
    'souq_books': '$basePath/كتب ومجلات وتعليم.png',
    'souq_music': '$basePath/موسيقى والات موسيقيه.png',
    'souq_hobbies': '$basePath/هوايات وتحف ومقتنيات.png',
    'souq_jewelry': '$basePath/مجوهرات وذهب وفضه.png',
    'souq_building': '$basePath/building-materials.png',
    'souq_garden': '$basePath/gardens.png',
    'souq_food': '$basePath/طعام ومشروبات.png',
    'souq_misc': '$basePath/متفرقات اخرى.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
