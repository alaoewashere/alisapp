import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/main_category_icons.dart';

/// Loads a local category PNG with a light plate and visible fallback on failure.
class CategoryAssetImage extends StatelessWidget {
  const CategoryAssetImage({
    super.key,
    required this.assetPath,
    required this.size,
    this.fallback,
    this.showPlate = true,
    this.color,
  });

  final String assetPath;
  final double size;
  final Widget? fallback;
  final bool showPlate;

  /// When set, recolors the PNG via [BlendMode.srcIn]. Main category icons on
  /// dark surfaces default to white when [showPlate] is false.
  final Color? color;

  Color? get _effectiveTint {
    if (color != null) return color;
    if (!showPlate && MainCategoryIcons.isMainCategoryAsset(assetPath)) {
      return AppColors.pureWhite;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Widget image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      gaplessPlayback: true,
      errorBuilder: (context, error, stackTrace) {
        return fallback ??
            Icon(
              Icons.category_outlined,
              size: size * 0.62,
              color: Colors.grey.shade600,
            );
      },
    );

    final tint = _effectiveTint;
    if (tint != null) {
      image = ColorFiltered(
        colorFilter: ColorFilter.mode(tint, BlendMode.srcIn),
        child: image,
      );
    }

    if (!showPlate) return image;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F4F5),
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: const Color(0xFFE4E4E7)),
      ),
      alignment: Alignment.center,
      child: Padding(
        padding: EdgeInsets.all(size * 0.1),
        child: image,
      ),
    );
  }
}
