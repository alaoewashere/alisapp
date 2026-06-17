import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../core/constants/app_colors.dart';
import '../core/utils/arabic_number.dart';

const _starGold = Color(0xFFF5A623);

/// Shows filled/half/empty stars + numeric rating + optional count.
///
/// Example: ★★★★☆ 4.2 (18 تقييم)
Widget starDisplay({
  required double rating,
  required int count,
  double starSize = 14,
  bool showCount = true,
  VoidCallback? onTap,
  TextStyle? textStyle,
}) {
  return StarDisplay(
    rating: rating,
    count: count,
    starSize: starSize,
    showCount: showCount,
    onTap: onTap,
    textStyle: textStyle,
  );
}

class StarDisplay extends StatelessWidget {
  const StarDisplay({
    super.key,
    required this.rating,
    required this.count,
    this.starSize = 14,
    this.showCount = true,
    this.onTap,
    this.textStyle,
  });

  final double rating;
  final int count;
  final double starSize;
  final bool showCount;
  final VoidCallback? onTap;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    final labelStyle = textStyle ??
        AppFonts.cairo(
          fontSize: starSize * 0.95,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        );

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _StarRow(rating: rating, size: starSize),
        SizedBox(width: starSize * 0.35),
        Text(
          rating.toStringAsFixed(1),
          style: labelStyle,
        ),
        if (showCount) ...[
          SizedBox(width: starSize * 0.25),
          Text(
            '(${arabicNumber(count)} تقييم)',
            style: labelStyle.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
              fontSize: (labelStyle.fontSize ?? 14) - 1,
            ),
          ),
        ],
      ],
    );

    if (onTap == null) return content;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: content,
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  const _StarRow({required this.rating, required this.size});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starValue = index + 1;
        IconData icon;
        Color color;

        if (rating >= starValue) {
          icon = Icons.star_rounded;
          color = _starGold;
        } else if (rating >= starValue - 0.5) {
          icon = Icons.star_half_rounded;
          color = _starGold;
        } else {
          icon = Icons.star_outline_rounded;
          color = AppColors.textMuted.withValues(alpha: 0.55);
        }

        return Icon(icon, size: size, color: color);
      }),
    );
  }
}

/// Compact amber badge for listing cards: ★ 4.8
class SellerRatingBadge extends StatelessWidget {
  const SellerRatingBadge({
    super.key,
    required this.avgRating,
  });

  final double avgRating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, size: 12, color: _starGold),
          const SizedBox(width: 2),
          Text(
            avgRating.toStringAsFixed(1),
            style: AppFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
