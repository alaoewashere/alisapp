/// Local PNG icons for الإلكترونيات and its subcategories (`assets/electronics-icons/`).
abstract final class ElectronicsCategoryIcons {
  static const basePath = 'assets/electronics-icons';

  static const Map<String, String> bySlug = {
    'electronics': '$basePath/Main.png',
    'elec_smartphones': '$basePath/هواتف ذكيه.png',
    'elec_tablets': '$basePath/اجهزه لوحيه.png',
    'elec_laptops': '$basePath/لابتوب وكمبيوتر.png',
    'elec_displays': '$basePath/شاشات وتلفزيونات.png',
    'elec_cameras': '$basePath/كاميرات.png',
    'elec_audio': '$basePath/سماعات وصوتيات.png',
    'elec_gaming': '$basePath/العاب فيديو.png',
    'elec_wearables': '$basePath/ساعات ذكيه واكسسوار.png',
    'elec_printers': '$basePath/طابعات وملحقات.png',
    'elec_networking': '$basePath/شبكات وراوتر.png',
    'elec_parts': '$basePath/قطع غيار واكسسوارات.png',
    'elec_appliances': '$basePath/احهزه المنزل الذكيه.png',
    'elec_ac': '$basePath/مكيفات.png',
    'elec_desktops': '$basePath/كمبيوتر مكتبي.png',
    'elec_drones': '$basePath/drones.png',
    'elec_projectors': '$basePath/بروجكتور وشاشه عرض.png',
    'elec_medical': '$basePath/اجهزه طبيه منزليه .png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
