import 'buy_sell_category_icons.dart';
import 'category_fallback_icon.dart';
import 'electronics_category_icons.dart';
import 'home_help_category_icons.dart';
import 'jobs_category_icons.dart';
import 'main_category_icons.dart';
import 'pets_category_icons.dart';
import 'real_estate_category_icons.dart';
import 'tutoring_category_icons.dart';
import 'vehicle_category_icons.dart';

/// Resolves local PNG category icons across all asset packs.
abstract final class CategoryAssetIcons {
  static String? assetForSlug(String slug) {
    return MainCategoryIcons.assetForSlug(slug) ??
        VehicleCategoryIcons.assetForSlug(slug) ??
        RealEstateCategoryIcons.assetForSlug(slug) ??
        ElectronicsCategoryIcons.assetForSlug(slug) ??
        BuySellCategoryIcons.assetForSlug(slug) ??
        TutoringCategoryIcons.assetForSlug(slug) ??
        JobsCategoryIcons.assetForSlug(slug) ??
        PetsCategoryIcons.assetForSlug(slug) ??
        HomeHelpCategoryIcons.assetForSlug(slug);
  }

  /// Pack icon first, then default packet icon for other category trees.
  static String? displayAssetForSlug(String slug) {
    return assetForSlug(slug) ?? CategoryFallbackIcon.assetForSlug(slug);
  }

  static bool hasAsset(String slug) => assetForSlug(slug) != null;

  static bool hasDisplayAsset(String slug) => displayAssetForSlug(slug) != null;
}
