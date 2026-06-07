import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/browse_categories.dart';

/// Single Sahibinden-style category row (72px, 48px icon circle, RTL).
/// Used on the search tab top-level category list only.
class CategoryBrowseRow extends StatelessWidget {
  const CategoryBrowseRow({
    super.key,
    required this.item,
    required this.onTap,
  });

  final BrowseCategoryItem item;
  final VoidCallback onTap;

  static const _rowHeight = 72.0;
  static const _iconSize = 48.0;

  @override
  Widget build(BuildContext context) {
    final style = item.style;

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
                Container(
                  width: _iconSize,
                  height: _iconSize,
                  decoration: BoxDecoration(
                    color: style.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, color: style.color, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        style.nameAr,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: GoogleFonts.cairo(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF212121),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
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
                  ),
                ),
                Icon(
                  Icons.chevron_left,
                  color: Colors.grey.shade400,
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
