import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';

/// Flat palm-tree brand logo — no shadow or background card.
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      AppAssets.appLogo,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
    );
  }
}

/// Compact header row: logo + brand name for RTL home app bar.
class AppBrandHeader extends StatelessWidget {
  const AppBrandHeader({
    super.key,
    this.logoSize = 36,
    this.subtitle,
    this.showSubtitle = true,
  });

  final double logoSize;
  final String? subtitle;
  final bool showSubtitle;

  static const brandNameAr = 'Sello';

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogo(size: logoSize),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              brandNameAr,
              style: AppFonts.cairo(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
                height: 1.1,
              ),
            ),
            if (showSubtitle)
              Text(
                subtitle ?? 'العراق',
                style: AppFonts.cairo(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
