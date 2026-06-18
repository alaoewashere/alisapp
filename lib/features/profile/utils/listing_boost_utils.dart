import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/package_badge.dart';
import '../../listings/constants/listing_package_config.dart';

/// Highest paid tier the user has purchased (from [listing_purchases]).
enum UserSubscriptionTier {
  standard,
  pro,
  premium;

  static UserSubscriptionTier fromPurchases(Iterable<String?> packageTypes) {
    var tier = UserSubscriptionTier.standard;
    for (final raw in packageTypes) {
      final pkg = ListingPackage.fromString(raw);
      if (pkg == ListingPackage.premium) return UserSubscriptionTier.premium;
      if (pkg == ListingPackage.pro) tier = UserSubscriptionTier.pro;
    }
    return tier;
  }

  ListingPackage get listingPackage => switch (this) {
        UserSubscriptionTier.premium => ListingPackage.premium,
        UserSubscriptionTier.pro => ListingPackage.pro,
        UserSubscriptionTier.standard => ListingPackage.standard,
      };
}

ListingPackage listingPackageFor(ListingModel listing) {
  return PackageBadge.packageForListing(listing) ?? ListingPackage.standard;
}

bool isListingBoostEligible({
  required ListingModel listing,
  required UserSubscriptionTier userTier,
}) {
  final postPackage = listingPackageFor(listing);
  return postPackage != ListingPackage.premium;
}

/// A single boost / upgrade choice in the bottom sheet.
class ListingBoostOption {
  const ListingBoostOption({
    required this.targetPackage,
    required this.priceIqd,
    required this.titleAr,
    required this.descriptionAr,
    required this.setFeatured,
    required this.setBoosted,
    required this.upgradePackage,
  });

  final ListingPackage targetPackage;
  final int priceIqd;
  final String titleAr;
  final String descriptionAr;
  final bool setFeatured;
  final bool setBoosted;
  final bool upgradePackage;
}

List<ListingBoostOption> listingBoostOptions({
  required ListingPackage postPackage,
}) {
  if (postPackage == ListingPackage.premium) return const [];

  final premiumPrice =
      ListingPackageConfig.optionFor(ListingPackage.premium).priceIqd;
  final proPrice = ListingPackageConfig.optionFor(ListingPackage.pro).priceIqd;

  if (postPackage == ListingPackage.standard) {
    return [
      ListingBoostOption(
        targetPackage: ListingPackage.pro,
        priceIqd: proPrice,
        titleAr: 'ترقية إلى برو',
        descriptionAr: 'يظهر إعلانك في أعلى قسم أحدث النشرات والمعروضات',
        setFeatured: false,
        setBoosted: true,
        upgradePackage: true,
      ),
      ListingBoostOption(
        targetPackage: ListingPackage.premium,
        priceIqd: premiumPrice,
        titleAr: 'ترقية إلى مميز',
        descriptionAr: 'يظهر إعلانك في أعلى قسم إعلانات المميزة',
        setFeatured: true,
        setBoosted: false,
        upgradePackage: true,
      ),
    ];
  }

  return [
    ListingBoostOption(
      targetPackage: ListingPackage.premium,
      priceIqd: premiumPrice,
      titleAr: 'ترقية إلى مميز',
      descriptionAr:
          'ينتقل إعلانك إلى أعلى قسم إعلانات المميزة في الصفحة الرئيسية',
      setFeatured: true,
      setBoosted: false,
      upgradePackage: true,
    ),
  ];
}
