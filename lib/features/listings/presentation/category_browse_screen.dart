import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/navigation_guard.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/sello_app_bar.dart';
import '../data/categories_repository.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/category_bento_grid.dart';
import '../widgets/category_tree_row.dart';

/// Drill-down category browser (used for العقارات and any category with children).
class CategoryBrowseScreen extends ConsumerWidget {
  const CategoryBrowseScreen({
    super.key,
    required this.categoryId,
    this.listingType,
  });

  final int categoryId;
  final ListingType? listingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(allCategoriesProvider);
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);

    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: AppColors.background,
        textTheme: AppFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: SelloAppBar(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          title: allAsync.when(
            data: (all) {
              final current = categoryById(categoryId, all);
              return Text(
                current?.localizedName(localeCode) ?? strings.categories,
              );
            },
            loading: () => Text(strings.categories),
            error: (_, _) => Text(strings.categories),
          ),
        ),
        body: allAsync.when(
          loading: () => const CategoryBentoGridShimmer(),
          error: (e, _) => AppErrorWidget(
            message: '$e',
            onRetry: () => ref.invalidate(allCategoriesProvider),
          ),
          data: (all) {
            final entry = categoryById(categoryId, all);
            final effectiveType =
                listingType ?? defaultListingTypeForCategory(entry);
            final listParentId = effectiveBrowseParentId(categoryId, all);
            return _CategoryTreeBody(
              categoryId: categoryId,
              listParentId: listParentId,
              all: all,
              listingType: effectiveType,
            );
          },
        ),
      ),
    );
  }
}

class _CategoryTreeBody extends ConsumerWidget {
  const _CategoryTreeBody({
    required this.categoryId,
    required this.listParentId,
    required this.all,
    required this.listingType,
  });

  final int categoryId;
  final int listParentId;
  final List<CategoryModel> all;
  final ListingType? listingType;

  Future<void> _onTap(
    BuildContext context,
    WidgetRef ref,
    CategoryModel category,
  ) async {
    final typeParam =
        (listingType ?? defaultListingTypeForCategory(category))?.value;

    var openBrowse =
        shouldNavigateToCategoryBrowse(category, all);
    if (!openBrowse && isKnownBrowseBranch(category)) {
      final kids = await ref
          .read(categoriesRepositoryProvider)
          .fetchChildren(category.id);
      openBrowse = kids.isNotEmpty;
    }

    if (openBrowse) {
      if (context.mounted) {
        context.pushGuarded(
          AppRoutes.categoryBrowsePath(category.id, listingType: typeParam),
        );
      }
    } else {
      if (context.mounted) {
        context.pushGuarded(
          AppRoutes.listingsPath('${category.id}', listingType: typeParam),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final current = categoryById(categoryId, all);
    final childrenAsync =
        ref.watch(categoryBrowseChildrenProvider(listParentId));
    final showBrandStyle = isVehicleBrandListParent(current) ||
        (current?.slug == vehicleRentalSlug &&
            listParentId != categoryId);
    final countsAsync = ref.watch(
      categoryListingCountsProvider(listingType?.value),
    );

    return childrenAsync.when(
      loading: () => const CategoryBentoGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: '$e',
        onRetry: () =>
            ref.invalidate(categoryBrowseChildrenProvider(listParentId)),
      ),
      data: (children) {
        if (children.isEmpty) {
          return Center(
            child: Text(
              strings.noSubcategories,
              style: AppFonts.cairo(color: AppColors.textMuted),
            ),
          );
        }

        final directCounts = countsAsync.maybeWhen(
          data: (counts) => counts,
          orElse: () => const <int, int>{},
        );
        final countsLoading = countsAsync.isLoading;
        final categoryName =
            current?.localizedName(localeCode) ?? strings.categories;
        final typeParam =
            (listingType ?? defaultListingTypeForCategory(current))?.value;
        final allListingsCount = subtreeListingCount(
          categoryId,
          all,
          directCounts,
        );

        final path = buildCategoryPath(categoryId, all);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (path.length > 1)
              _CategoryBreadcrumb(path: path, localeCode: localeCode),
            CategoryAllListingsRow(
              categoryName: categoryName,
              listingCount: countsLoading ? null : allListingsCount,
              loading: countsLoading,
              onTap: () {
                if (context.mounted) {
                  context.pushGuarded(
                    AppRoutes.listingsPath(
                      '$categoryId',
                      listingType: typeParam,
                    ),
                  );
                }
              },
            ),
            Expanded(
              child: CategoryBentoGrid(
                categories: children,
                all: all,
                showBrandStyle: showBrandStyle,
                listingCounts: directCounts,
                onTap: (category) => _onTap(context, ref, category),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Tappable path (root › … › current) so users stay oriented in deep trees
/// and can jump back to any level.
class _CategoryBreadcrumb extends StatelessWidget {
  const _CategoryBreadcrumb({required this.path, required this.localeCode});

  final List<CategoryModel> path;
  final String localeCode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: AlignmentDirectional.centerStart,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var i = 0; i < path.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: Icon(
                    Icons.chevron_left,
                    size: 14,
                    color: AppColors.textMuted.withValues(alpha: 0.5),
                  ),
                ),
              GestureDetector(
                onTap: i == path.length - 1
                    ? null
                    : () => context.pushGuarded(
                          AppRoutes.categoryBrowsePath(path[i].id),
                        ),
                child: Text(
                  path[i].localizedName(localeCode),
                  style: AppFonts.cairo(
                    fontSize: 12.5,
                    fontWeight: i == path.length - 1
                        ? FontWeight.w800
                        : FontWeight.w500,
                    color: i == path.length - 1
                        ? AppColors.volt
                        : AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
