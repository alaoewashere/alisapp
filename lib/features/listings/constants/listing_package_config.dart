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
    this.originalPriceIqd,
    this.discountPercent,
    required this.features,
  });

  final ListingPackage package;
  final String labelAr;
  final int priceIqd;
  final int? originalPriceIqd;
  final int? discountPercent;
  final List<ListingPackageFeature> features;

  bool get isFree => priceIqd <= 0;
}

abstract final class ListingPackageConfig {
  static const options = [
    ListingPackageOption(
      package: ListingPackage.standard,
      labelAr: 'إعلان عادي',
      priceIqd: 0,
      features: [
        ListingPackageFeature(
          title: '30 يوم',
          description: 'يُنشر إعلانك لمدة 30 يوماً',
        ),
        ListingPackageFeature(
          title: 'ظهور عادي',
          description: 'يظهر في نتائج البحث ضمن الإعلانات العادية',
        ),
        ListingPackageFeature(
          title: 'رسائل واتصال',
          description: 'يتواصل معك المشترون حسب تفضيلاتك',
        ),
      ],
    ),
    ListingPackageOption(
      package: ListingPackage.pro,
      labelAr: 'إعلان برو',
      priceIqd: 99,
      originalPriceIqd: 114,
      discountPercent: 13,
      features: [
        ListingPackageFeature(
          title: '45 يوم',
          description: 'يُنشر إعلانك لمدة 45 يوماً',
        ),
        ListingPackageFeature(
          title: 'تعزيز في البحث',
          description: 'يظهر أعلى من الإعلانات العادية في نفس الفئة',
        ),
        ListingPackageFeature(
          title: 'شارة برو',
          description: 'شارة مميزة على بطاقة الإعلان',
        ),
      ],
    ),
    ListingPackageOption(
      package: ListingPackage.premium,
      labelAr: 'إعلان مميز',
      priceIqd: 199,
      originalPriceIqd: 229,
      discountPercent: 13,
      features: [
        ListingPackageFeature(
          title: '60 يوم',
          description: 'يُنشر إعلانك لمدة 60 يوماً',
        ),
        ListingPackageFeature(
          title: 'ظهور في المميز',
          description: 'يُعرض في قسم الإعلانات المميزة بالصفحة الرئيسية',
        ),
        ListingPackageFeature(
          title: 'أولوية قصوى',
          description: 'أعلى ظهور في نتائج البحث والفئة',
        ),
      ],
    ),
  ];

  static ListingPackageOption optionFor(ListingPackage package) {
    return options.firstWhere((option) => option.package == package);
  }
}
