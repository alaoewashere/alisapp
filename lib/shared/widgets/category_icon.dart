import 'category_asset_image.dart';
import '../../core/utils/cached_network_image_utils.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/category_asset_icons.dart';
import '../../core/constants/category_fallback_icon.dart';
import '../../core/constants/main_category_icons.dart';
import '../../core/utils/category_tree.dart';
import '../../features/home/widgets/category_grid.dart';
import '../../features/listings/widgets/vehicle_brand_logo.dart';
import '../models/category_model.dart';

/// Category tile icon — vehicle PNGs, brand logos, remote logo, then emoji fallback.
class CategoryIcon extends StatelessWidget {
  const CategoryIcon({
    super.key,
    required this.category,
    this.size = 48,
    this.showBrandStyle = false,
    this.accent,
  });

  final CategoryModel category;
  final double size;
  final bool showBrandStyle;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    if (showBrandStyle && isVehicleBrand(category)) {
      return VehicleBrandLogo(category: category, size: size);
    }

    if (shouldUseVehicleBrandLogo(category)) {
      return VehicleBrandLogo(category: category, size: size);
    }

    final assetPath = CategoryAssetIcons.assetForSlug(category.slug);
    if (assetPath != null) {
      final isMainCategory = MainCategoryIcons.hasAsset(category.slug);
      return CategoryAssetImage(
        assetPath: assetPath,
        size: size,
        showPlate: !isMainCategory,
        color: isMainCategory ? AppColors.pureWhite : null,
        fallback: _EmojiIconBox(
          category: category,
          accent: accent ?? parseCategoryColor(category.colorHex),
          size: size,
        ),
      );
    }

    final resolvedAccent = accent ?? parseCategoryColor(category.colorHex);

    if (category.logoUrl != null && category.logoUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: resolvedAccent.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size * 0.29),
        ),
        clipBehavior: Clip.antiAlias,
        child: cachedListingImage(
          context: context,
          imageUrl: category.logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorWidget: (_, _, _) =>
              _EmojiIconBox(category: category, accent: resolvedAccent, size: size),
        ),
      );
    }

    final fallbackPath = CategoryFallbackIcon.assetForSlug(category.slug);
    if (fallbackPath != null) {
      return CategoryAssetImage(
        assetPath: fallbackPath,
        size: size,
        fallback: _EmojiIconBox(
          category: category,
          accent: resolvedAccent,
          size: size,
        ),
      );
    }

    return _EmojiIconBox(
      category: category,
      accent: resolvedAccent,
      size: size,
    );
  }
}

class _EmojiIconBox extends StatelessWidget {
  const _EmojiIconBox({
    required this.category,
    required this.accent,
    required this.size,
  });

  final CategoryModel category;
  final Color accent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final glyph = _resolveGlyph(category.icon);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(size * 0.29),
      ),
      alignment: Alignment.center,
      child: glyph == CategoryGrid.packagePlaceholderEmoji
          ? Padding(
              padding: EdgeInsets.all(size * 0.14),
              child: Image.asset(
                CategoryFallbackIcon.assetPath,
                width: size * 0.72,
                height: size * 0.72,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    glyph,
                    style: TextStyle(fontSize: size * 0.5),
                  );
                },
              ),
            )
          : Text(glyph, style: TextStyle(fontSize: size * 0.5)),
    );
  }
}

String _resolveGlyph(String icon) {
  const materialIcons = {
    'home',
    'directions_car',
    'devices',
    'work',
    'handyman',
    'category',
    'brand',
    'model',
  };
  if (!materialIcons.contains(icon)) {
    return icon;
  }
  return CategoryGrid.emojiFor(icon);
}
