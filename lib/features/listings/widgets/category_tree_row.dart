import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/category_tree.dart';
import '../../../shared/models/category_model.dart';
import 'vehicle_brand_logo.dart';

/// Sahibinden-style row for drilling into the category tree.
class CategoryTreeRow extends StatelessWidget {
  const CategoryTreeRow({
    super.key,
    required this.category,
    required this.subtitle,
    required this.onTap,
    this.showBrandStyle = false,
    this.listingCount,
  });

  final CategoryModel category;
  final String subtitle;
  final VoidCallback onTap;
  final bool showBrandStyle;
  final int? listingCount;

  static const _rowHeight = 72.0;
  static const _iconSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final isBrandRow = showBrandStyle && isVehicleBrand(category);
    final showSubtitle = subtitle.isNotEmpty && !isBrandRow;

    return Material(
      color: AppColors.fieldCarbon,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: _rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                if (isBrandRow) ...[
                  VehicleBrandLogo(category: category, size: _iconSize),
                  const SizedBox(width: 14),
                ],
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        category.nameAr,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      if (showSubtitle) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppFonts.cairo(
                            fontSize: 13,
                            color: AppColors.textMuted,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (listingCount != null) ...[
                  Text(
                    arabicNumber(listingCount!),
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                const Icon(Icons.chevron_left, color: AppColors.textMuted, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Top-of-list "show all listings in this category" row for category browse.
class CategoryAllListingsRow extends StatelessWidget {
  const CategoryAllListingsRow({
    super.key,
    required this.categoryNameAr,
    required this.onTap,
    this.listingCount,
    this.loading = false,
  });

  final String categoryNameAr;
  final VoidCallback? onTap;
  final int? listingCount;
  final bool loading;

  static const _rowHeight = 72.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: SizedBox(
          height: _rowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.volt,
                  size: 28,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'كل إعلانات $categoryNameAr',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppFonts.cairo(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.volt,
                      height: 1.2,
                    ),
                  ),
                ),
                if (loading)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.volt,
                    ),
                  )
                else if (listingCount != null)
                  Text(
                    arabicNumber(listingCount!),
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_left,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
