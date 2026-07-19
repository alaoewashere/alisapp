import '../../../shared/models/listing_model.dart';

class ListingPackageFeature {
  const ListingPackageFeature({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class ListingPackageOption {
  const ListingPackageOption({
    required this.package,
    required this.labelAr,
    required this.priceIqd,
    required this.durationLabelAr,
    required this.features,
    this.originalPriceIqd,
    this.discountPercent,
  });

  final ListingPackage package;
  final String labelAr;
  final int priceIqd;
  final String durationLabelAr;
  final List<ListingPackageFeature> features;
  final int? originalPriceIqd;
  final int? discountPercent;
}

abstract final class ListingPackageConfig {
  /// When false, only standard tier is selectable; pro/premium show "Coming soon".
  static const proAndPremiumEnabled = true;

  /// Fee when posting standard tier after the free quota is used.
  static const paidStandardPriceIqd = 5000;

  static bool isSelectable(ListingPackage package) {
    if (package == ListingPackage.standard) return true;
    return proAndPremiumEnabled;
  }

  static const options = [
    ListingPackageOption(
      package: ListingPackage.standard,
      labelAr: 'إعلان عادي',
      priceIqd: paidStandardPriceIqd,
      durationLabelAr: '30 يوم',
      features: [
        ListingPackageFeature(
          title: 'إعلان أساسي',
          description: 'ينشر في نتائج البحث ضمن الإعلانات العادية',
        ),
        ListingPackageFeature(
          title: 'رسائل واتصال',
          description: 'يتواصل المشترون حسب تفضيلاتك',
        ),
      ],
    ),
    ListingPackageOption(
      package: ListingPackage.pro,
      labelAr: 'إعلان برو',
      priceIqd: 8000,
      durationLabelAr: '60 يوم',
      features: [
        ListingPackageFeature(
          title: 'شارة بروفايل موثق',
          description: 'تعزيز ثقة البائع على بطاقة الإعلان',
        ),
        ListingPackageFeature(
          title: 'ظهور أعلى',
          description: 'يظهر قبل الإعلانات العادية في نفس الفئة',
        ),
        ListingPackageFeature(
          title: 'تجديد تلقائي أسبوعي',
          description: 'يعود إعلانك لأعلى الفئة تلقائياً كل أسبوع',
        ),
        ListingPackageFeature(
          title: 'صور وفيديو أكثر',
          description: 'أضف حتى 15 صورة وفيديو واحد للإعلان',
        ),
        ListingPackageFeature(
          title: 'زر واتساب مباشر',
          description: 'تواصل فوري عبر واتساب من بطاقة الإعلان',
        ),
        ListingPackageFeature(
          title: 'إطار وشارة برو',
          description: 'إطار مميّز وشارة "برو" تبرز إعلانك في البحث',
        ),
        ListingPackageFeature(
          title: 'إحصائيات',
          description: 'مشاهدات وتواصل مع الإعلان',
        ),
      ],
    ),
    ListingPackageOption(
      package: ListingPackage.premium,
      labelAr: 'إعلان مميز',
      priceIqd: 12000,
      durationLabelAr: '90 يوم',
      features: [
        ListingPackageFeature(
          title: 'كروسيل المميز',
          description: 'يُعرض في قسم الإعلانات المميزة بالصفحة الرئيسية',
        ),
        ListingPackageFeature(
          title: 'أعلى ترتيب',
          description: 'أولوية قصوى في نتائج البحث والفئة',
        ),
        ListingPackageFeature(
          title: 'تجديد تلقائي يومي',
          description: 'يعود إعلانك لأعلى الفئة تلقائياً كل يوم',
        ),
        ListingPackageFeature(
          title: 'إشعار للمشترين المهتمين',
          description: 'إشعار يصل للمهتمين بفئة إعلانك',
        ),
        ListingPackageFeature(
          title: 'إحصائيات متقدمة',
          description: 'تحليلات مفصّلة: مصادر المشاهدات وأوقات الذروة',
        ),
        ListingPackageFeature(
          title: 'تعزيز دفع',
          description: 'ظهور مميز لزيادة المشاهدات',
        ),
      ],
    ),
  ];

  static ListingPackageOption optionFor(ListingPackage package) {
    return options.firstWhere((option) => option.package == package);
  }

  static int purchasePriceIqd(
    ListingPackage package, {
    bool standardOverQuota = false,
  }) {
    if (package == ListingPackage.standard) {
      return standardOverQuota ? paidStandardPriceIqd : 0;
    }
    return optionFor(package).priceIqd;
  }
}
