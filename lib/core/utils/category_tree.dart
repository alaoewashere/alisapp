import 'package:flutter/material.dart';

import '../l10n/category_fallback_subtitles.dart';
import '../l10n/category_locale.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/listing_model.dart';

/// Root category slugs that use the full drill-down browse tree.
const categoryBrowseRootSlugs = {
  'real_estate',
  'cars',
  'electronics',
  'buy_sell',
  'tutoring',
  'jobs',
  'pets',
  'home_help',
};

bool isCategoryBrowseRoot(CategoryModel? category) {
  return category != null && categoryBrowseRootSlugs.contains(category.slug);
}

/// Parent slugs whose direct children are vehicle brands.
const vehicleBrandListParentSlugs = {
  'veh_automobile',
  'veh_damaged',
  'veh_accessible',
  'veh_suv_pickup',
  'veh_electric',
  'veh_commercial',
  'veh_motorcycle',
  'veh_minivan',
  'veh_marine',
  'veh_caravan',
  'veh_classic',
  'veh_aircraft_planes',
  'veh_aircraft_helicopters',
};

/// Electronics subcategory slugs whose direct children are brands.
const electronicsBrandListParentSlugs = {
  'elec_smartphones',
  'elec_tablets',
  'elec_laptops',
  'elec_displays',
  'elec_cameras',
  'elec_audio',
  'elec_gaming',
  'elec_wearables',
  'elec_printers',
  'elec_networking',
  'elec_appliances',
  'elec_ac',
  'elec_desktops',
  'elec_drones',
  'elec_projectors',
};

bool isVehicleBrandListParent(CategoryModel? category) {
  return category != null &&
      (vehicleBrandListParentSlugs.contains(category.slug) ||
          electronicsBrandListParentSlugs.contains(category.slug));
}

/// Vehicle branch that reuses [vehicleAutomobileSlug] brand tree for rentals.
const vehicleRentalSlug = 'veh_rental';

const vehicleAutomobileSlug = 'veh_automobile';

/// Slugs that open the shared automobile brand/model tree.
const vehicleSharedBrandTreeSlugs = {vehicleAutomobileSlug, vehicleRentalSlug};

bool isVehicleSharedBrandTreeEntry(CategoryModel? category) {
  return category != null && vehicleSharedBrandTreeSlugs.contains(category.slug);
}

/// True when tapping [category] should open the browse screen (not listings).
bool shouldNavigateToCategoryBrowse(
  CategoryModel category,
  List<CategoryModel> all,
) {
  if (isVehicleSharedBrandTreeEntry(category)) return true;
  if (isVehicleBrandListParent(category)) return true;
  if (isCategoryBrowseRoot(category)) return true;
  if (categoryHasChildren(category.id, all)) return true;
  return false;
}

/// Whether drill-down should open browse even when the in-memory tree is incomplete.
bool isKnownBrowseBranch(CategoryModel category) {
  return isVehicleSharedBrandTreeEntry(category) ||
      isVehicleBrandListParent(category) ||
      isCategoryBrowseRoot(category) ||
      isVehicleBrand(category);
}

CategoryModel? categoryBySlug(String slug, List<CategoryModel> all) {
  for (final c in all) {
    if (c.slug == slug) return c;
  }
  return null;
}

/// When browsing سيارات للإيجار, show brands from سيارات (same tree).
int effectiveBrowseParentId(int categoryId, List<CategoryModel> all) {
  final current = categoryById(categoryId, all);
  if (current?.slug == vehicleRentalSlug) {
    return categoryBySlug(vehicleAutomobileSlug, all)?.id ?? categoryId;
  }
  return categoryId;
}

/// Default listing type filter for a vehicle branch entry.
ListingType? defaultListingTypeForCategory(CategoryModel? category) {
  return switch (category?.slug) {
    vehicleAutomobileSlug => ListingType.sale,
    vehicleRentalSlug => ListingType.rent,
    _ => null,
  };
}

bool isVehicleBrand(CategoryModel category) => category.icon == 'brand';

bool isVehicleModel(CategoryModel category) => category.icon == 'model';

/// Vehicle brand/model tiles use [VehicleBrandLogo]; tutoring subjects also use
/// `model` icon but should resolve to the default category PNG instead.
bool shouldUseVehicleBrandLogo(CategoryModel category) {
  if (category.slug.startsWith('tutor_')) return false;
  return isVehicleBrand(category) || isVehicleModel(category);
}

/// Sorts categories by [displayOrder] then [id].
List<CategoryModel> sortCategories(List<CategoryModel> items) {
  return [...items]..sort((a, b) {
      final order = a.displayOrder.compareTo(b.displayOrder);
      if (order != 0) return order;
      return a.id.compareTo(b.id);
    });
}

List<CategoryModel> childrenOf(int? parentId, List<CategoryModel> all) {
  return sortCategories(all.where((c) => c.parentId == parentId).toList());
}

bool categoryHasChildren(int categoryId, List<CategoryModel> all) {
  return all.any((c) => c.parentId == categoryId);
}

CategoryModel? categoryById(int id, List<CategoryModel> all) {
  for (final c in all) {
    if (c.id == id) return c;
  }
  return null;
}

/// Root-to-leaf path for a category id (empty when [categoryId] is unknown).
List<CategoryModel> buildCategoryPath(int categoryId, List<CategoryModel> all) {
  final byId = {for (final c in all) c.id: c};
  final path = <CategoryModel>[];
  var current = byId[categoryId];
  while (current != null) {
    path.insert(0, current);
    current = current.parentId != null ? byId[current.parentId] : null;
  }
  return path;
}

/// Resolves a search browse row to a live DB category (slug first, then cached id).
CategoryModel? resolveBrowseCategory(
  String slug,
  List<CategoryModel> all, {
  int? categoryId,
}) {
  return categoryBySlug(slug, all) ??
      (categoryId != null ? categoryById(categoryId, all) : null);
}

Color parseCategoryColor(String? hex, {Color fallback = const Color(0xFF757575)}) {
  if (hex == null || hex.isEmpty) return fallback;
  final value = hex.replaceFirst('#', '');
  if (value.length != 6) return fallback;
  final parsed = int.tryParse(value, radix: 16);
  if (parsed == null) return fallback;
  return Color(0xFF000000 | parsed);
}

String subtitleForCategory(
  CategoryModel category,
  List<CategoryModel> all, {
  String localeCode = 'ar',
}) {
  final code = CategoryModel.normalizeAppLocaleCode(localeCode);

  final dbDesc = category.displayDescription(code);
  if (dbDesc.isNotEmpty) return dbDesc;

  final override = categoryFallbackSubtitle(category.slug, code);
  if (override.isNotEmpty) return override;

  final subs = childrenOf(category.id, all);
  if (subs.isEmpty) return '';

  final sep = categorySubtitleSeparator(code);
  return subs.take(4).map((c) => c.localizedName(code)).join(sep);
}

/// All descendant category IDs (excluding [rootId] itself).
Set<int> descendantCategoryIds(int rootId, List<CategoryModel> all) {
  final result = <int>{};
  void walk(int parentId) {
    for (final c in all) {
      if (c.parentId == parentId) {
        result.add(c.id);
        walk(c.id);
      }
    }
  }

  walk(rootId);
  return result;
}

/// Approved active listings under [categoryId] and all descendants.
int subtreeListingCount(
  int categoryId,
  List<CategoryModel> all,
  Map<int, int> directCounts,
) {
  var total = directCounts[categoryId] ?? 0;
  for (final id in descendantCategoryIds(categoryId, all)) {
    total += directCounts[id] ?? 0;
  }
  return total;
}
