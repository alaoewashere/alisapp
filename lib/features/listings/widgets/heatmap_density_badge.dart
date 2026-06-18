import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/arabic_number.dart';

/// Fixed-pixel density badge for the listing heat map.
class HeatmapDensityBadge extends StatelessWidget {
  const HeatmapDensityBadge({
    super.key,
    required this.count,
    this.compact = false,
  });

  final int count;
  final bool compact;

  static const badgeSize = 40.0;
  static const glowSize = 52.0;

  @override
  Widget build(BuildContext context) {
    final diameter = compact ? 36.0 : badgeSize;
    final glowDiameter = compact ? 46.0 : glowSize;
    final fontSize = compact ? 12.0 : 14.0;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Container(
            width: glowDiameter,
            height: glowDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.volt.withValues(alpha: 0.18),
            ),
          ),
          Container(
            width: diameter,
            height: diameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.volt,
              border: Border.all(
                color: AppColors.canvas,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              arabicNumber(count),
              style: AppFonts.cairo(
                fontSize: fontSize,
                fontWeight: FontWeight.w800,
                color: AppColors.canvas,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
