import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import '../../home/widgets/category_grid.dart';
import 'vehicle_brand_logo.dart';

/// 2-column bento card for category pickers — souqly-redesign-studio categories mockup.
class CategoryBentoCard extends StatelessWidget {
  const CategoryBentoCard({
    super.key,
    required this.category,
    required this.subtitle,
    required this.onTap,
    this.selected = false,
    this.showBrandStyle = false,
    this.listingCount,
  });

  final CategoryModel category;
  final String subtitle;
  final VoidCallback? onTap;
  final bool selected;
  final bool showBrandStyle;
  final int? listingCount;

  @override
  Widget build(BuildContext context) {
    final isBrandRow = showBrandStyle && isVehicleBrand(category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : Colors.white,
            borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.35)
                  : AppColors.borderLight,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _CategoryBentoIcon(
                  category: category,
                  showBrandStyle: showBrandStyle,
                ),
                const SizedBox(height: 12),
                Text(
                  category.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
                if (subtitle.isNotEmpty && !isBrandRow) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.35,
                    ),
                  ),
                ],
                if (listingCount != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    arabicNumber(listingCount!),
                    style: GoogleFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryBentoIcon extends StatelessWidget {
  const _CategoryBentoIcon({
    required this.category,
    required this.showBrandStyle,
  });

  final CategoryModel category;
  final bool showBrandStyle;

  @override
  Widget build(BuildContext context) {
    if (showBrandStyle && isVehicleBrand(category)) {
      return VehicleBrandLogo(category: category, size: 48);
    }

    if (category.icon == 'brand' || category.icon == 'model') {
      return VehicleBrandLogo(category: category, size: 48);
    }

    final accent = parseCategoryColor(category.colorHex);

    if (category.logoUrl != null && category.logoUrl!.isNotEmpty) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: accent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        clipBehavior: Clip.antiAlias,
        child: CachedNetworkImage(
          imageUrl: category.logoUrl!,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) => _EmojiIconBox(category: category, accent: accent),
        ),
      );
    }

    return _EmojiIconBox(category: category, accent: accent);
  }
}

class _EmojiIconBox extends StatelessWidget {
  const _EmojiIconBox({
    required this.category,
    required this.accent,
  });

  final CategoryModel category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final emoji = CategoryGrid.emojiFor(category.icon);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      alignment: Alignment.center,
      child: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}

/// Two-column grid of [CategoryBentoCard] widgets with consistent spacing.
class CategoryBentoGrid extends StatelessWidget {
  const CategoryBentoGrid({
    super.key,
    required this.categories,
    required this.all,
    required this.onTap,
    this.loading = false,
    this.selectedId,
    this.showBrandStyle = false,
    this.listingCounts,
  });

  final List<CategoryModel> categories;
  final List<CategoryModel> all;
  final void Function(CategoryModel category) onTap;
  final bool loading;
  final int? selectedId;
  final bool showBrandStyle;
  final Map<int, int>? listingCounts;

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return Center(
        child: Text(
          'لا توجد فئات',
          style: GoogleFonts.cairo(color: AppColors.textMuted),
        ),
      );
    }

    return Stack(
      children: [
        GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.88,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final subtitle = subtitleForCategory(category, all);
            final selected = selectedId != null && selectedId == category.id;
            final count = showBrandStyle && isVehicleBrand(category)
                ? subtreeListingCount(category.id, all, listingCounts ?? {})
                : null;

            return CategoryBentoCard(
              category: category,
              subtitle: subtitle,
              selected: selected,
              showBrandStyle: showBrandStyle,
              listingCount: count,
              onTap: loading ? null : () => onTap(category),
            );
          },
        ),
        if (loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Color(0x44FFFFFF),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}

class CategoryBentoGridShimmer extends StatelessWidget {
  const CategoryBentoGridShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: 6,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          border: Border.all(color: AppColors.borderLight),
        ),
      ),
    );
  }
}
