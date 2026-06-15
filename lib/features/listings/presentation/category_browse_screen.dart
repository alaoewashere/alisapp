import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../data/categories_repository.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/category_bento_grid.dart';

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
        textTheme: GoogleFonts.cairoTextTheme(Theme.of(context).textTheme),
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
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

class _CategoryTreeBody extends ConsumerStatefulWidget {
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

  @override
  ConsumerState<_CategoryTreeBody> createState() => _CategoryTreeBodyState();
}

class _CategoryTreeBodyState extends ConsumerState<_CategoryTreeBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(categoryBrowseChildrenProvider(widget.listParentId));
      ref.invalidate(allCategoriesProvider);
    });
  }

  Future<void> _onTap(
    BuildContext context,
    CategoryModel category,
  ) async {
    final typeParam =
        (widget.listingType ?? defaultListingTypeForCategory(category))?.value;

    var openBrowse =
        shouldNavigateToCategoryBrowse(category, widget.all);
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
  Widget build(BuildContext context) {
    final current = categoryById(widget.categoryId, widget.all);
    final childrenAsync =
        ref.watch(categoryBrowseChildrenProvider(widget.listParentId));
    final showBrandStyle = isVehicleBrandListParent(current) ||
        (current?.slug == vehicleRentalSlug &&
            widget.listParentId != widget.categoryId);
    final countsAsync = ref.watch(
      categoryListingCountsProvider(widget.listingType?.value),
    );

    return childrenAsync.when(
      loading: () => const CategoryBentoGridShimmer(),
      error: (e, _) => AppErrorWidget(
        message: '$e',
        onRetry: () =>
            ref.invalidate(categoryBrowseChildrenProvider(widget.listParentId)),
      ),
      data: (children) {
        if (children.isEmpty) {
          return Center(
            child: Text(
              'لا توجد فئات فرعية',
              style: GoogleFonts.cairo(color: AppColors.textMuted),
            ),
          );
        }

        final directCounts = countsAsync.maybeWhen(
          data: (counts) => counts,
          orElse: () => const <int, int>{},
        );

        return CategoryBentoGrid(
          categories: children,
          all: widget.all,
          showBrandStyle: showBrandStyle,
          listingCounts: directCounts,
          onTap: (category) => _onTap(context, category),
        );
      },
    );
  }
}

class CategoryBrowseShimmer extends StatelessWidget {
  const CategoryBrowseShimmer({super.key});

  @override
  Widget build(BuildContext context) => const CategoryBentoGridShimmer();
}
