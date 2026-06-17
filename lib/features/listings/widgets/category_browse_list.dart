import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/browse_categories.dart';
import '../../../core/constants/category_asset_icons.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/category_asset_image.dart';
import '../../../shared/models/category_model.dart';

class CategoryBrowseList extends StatelessWidget {
  const CategoryBrowseList({
    super.key,
    required this.categories,
    required this.onCategoryTap,
  });

  final List<CategoryModel> categories;
  final void Function(BrowseCategoryItem item) onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final items = buildBrowseCategoryItems(categories);

    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        AppBottomNavLayout.scrollBottomPadding(context),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (_, index) {
        final item = items[index];
        return _BrowseCategoryBentoCard(
          item: item,
          onTap: () => onCategoryTap(item),
        );
      },
    );
  }
}

class _BrowseCategoryBentoCard extends StatelessWidget {
  const _BrowseCategoryBentoCard({
    required this.item,
    required this.onTap,
  });

  final BrowseCategoryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = item.style;
    final assetPath = CategoryAssetIcons.displayAssetForSlug(style.slug);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.fieldCarbon,
            borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: assetPath == null
                        ? style.color.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: assetPath != null
                      ? CategoryAssetImage(
                          assetPath: assetPath,
                          size: 44,
                          showPlate: false,
                          fallback: Icon(
                            style.icon,
                            size: 26,
                            color: style.color,
                          ),
                        )
                      : Icon(style.icon, size: 26, color: style.color),
                ),
                const SizedBox(height: 12),
                Text(
                  style.nameAr,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.25,
                  ),
                ),
                if (item.subtitle.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    item.subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontSize: 11,
                      color: AppColors.textMuted,
                      height: 1.35,
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

class CategoryBrowseListShimmer extends StatelessWidget {
  const CategoryBrowseListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        AppBottomNavLayout.scrollBottomPadding(context),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.88,
      ),
      itemCount: 8,
      itemBuilder: (_, _) => Container(
        decoration: BoxDecoration(
          color: AppColors.fieldCarbon,
          borderRadius: BorderRadius.circular(AppDecorations.cardRadius),
          border: Border.all(color: AppColors.glassBorder),
        ),
      ),
    );
  }
}
