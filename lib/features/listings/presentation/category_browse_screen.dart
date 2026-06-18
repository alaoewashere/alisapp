import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
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
              return Text(current?.nameAr ?? 'الفئات');
            },
            loading: () => const Text('الفئات'),
            error: (_, _) => const Text('الفئات'),
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
        context.push(
          AppRoutes.categoryBrowsePath(category.id, listingType: typeParam),
        );
      }
    } else {
      if (context.mounted) {
        context.push(
          AppRoutes.listingsPath('${category.id}', listingType: typeParam),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              'لا توجد فئات فرعية',
              style: AppFonts.cairo(color: AppColors.textMuted),
            ),
          );
        }

        final directCounts = countsAsync.maybeWhen(
          data: (counts) => counts,
          orElse: () => const <int, int>{},
        );
        final countsLoading = countsAsync.isLoading;
        final categoryName = current?.nameAr ?? 'الفئات';
        final typeParam =
            (listingType ?? defaultListingTypeForCategory(current))?.value;
        final allListingsCount = subtreeListingCount(
          categoryId,
          all,
          directCounts,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CategoryAllListingsRow(
              categoryNameAr: categoryName,
              listingCount: countsLoading ? null : allListingsCount,
              loading: countsLoading,
              onTap: () {
                if (context.mounted) {
                  context.push(
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
