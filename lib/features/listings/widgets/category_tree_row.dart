import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      color: Colors.white,
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
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF212121),
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
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: const Color(0xFF757575),
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
                    style: GoogleFonts.cairo(
                      fontSize: 14,
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
                Icon(Icons.chevron_left, color: Colors.grey.shade400, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
