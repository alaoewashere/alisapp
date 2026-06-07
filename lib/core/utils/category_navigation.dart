import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/app_router.dart';
import '../../shared/models/category_model.dart';
import 'category_tree.dart';

/// Opens the category tree browser for deep-tree roots, otherwise listings grid.
void openCategoryDestination(BuildContext context, CategoryModel category) {
  if (categoryBrowseRootSlugs.contains(category.slug)) {
    context.push(AppRoutes.categoryBrowsePath(category.id));
    return;
  }

  final listingType = defaultListingTypeForCategory(category)?.value;

  if (isVehicleSharedBrandTreeEntry(category) ||
      isVehicleBrandListParent(category)) {
    context.push(
      AppRoutes.categoryBrowsePath(category.id, listingType: listingType),
    );
    return;
  }

  context.push(
    AppRoutes.listingsPath('${category.id}', listingType: listingType),
  );
}

/// Opens browse or listings depending on whether [categoryId] has children.
void openCategoryById(
  BuildContext context,
  int categoryId,
  List<CategoryModel> all, {
  String? listingType,
}) {
  final category = categoryById(categoryId, all);
  final typeParam =
      listingType ?? defaultListingTypeForCategory(category)?.value;

  if (category != null && shouldNavigateToCategoryBrowse(category, all)) {
    context.push(
      AppRoutes.categoryBrowsePath(categoryId, listingType: typeParam),
    );
  } else {
    context.push(
      AppRoutes.listingsPath('$categoryId', listingType: typeParam),
    );
  }
}
