import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../models/listing_model.dart';

/// Visual size preset for [PackageBadge].
enum PackageBadgeSize {
  compact,
  medium,
  large,
}

/// Luxury metallic pill for listing package tiers (مجاني / برو / مميز).
class PackageBadge extends StatelessWidget {
  const PackageBadge({
    super.key,
    required this.package,
    this.size = PackageBadgeSize.medium,
    this.showStar,
    this.opacity = 1,
  });

  final ListingPackage package;
  final PackageBadgeSize size;
  final bool? showStar;
  final double opacity;

  /// Resolves the paid/free tier for a listing; null when standard (no badge).
  static ListingPackage? packageForListing(ListingModel listing) {
    if (listing.isPremiumListing) return ListingPackage.premium;
    if (listing.isProListing) return ListingPackage.pro;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final spec = _sizeSpec(size);
    final style = _PackageBadgeStyle.forPackage(package);
    final label = package.badgeLabelAr;
    final includeStar = showStar ?? package == ListingPackage.premium;

    final badge = ClipRRect(
      borderRadius: BorderRadius.circular(spec.radius),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: style.gradient,
                boxShadow: style.shadows,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.32),
                    Colors.white.withValues(alpha: 0.06),
                    Colors.black.withValues(alpha: 0.18),
                  ],
                  stops: const [0.0, 0.42, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                  width: 0.75,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: spec.hPad,
              vertical: spec.vPad,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (includeStar) ...[
                  Icon(
                    Icons.star_rounded,
                    size: spec.iconSize,
                    color: style.textColor,
                  ),
                  SizedBox(width: spec.iconGap),
                ],
                Text(
                  label,
                  style: AppFonts.cairo(
                    fontSize: spec.fontSize,
                    fontWeight: FontWeight.w800,
                    color: style.textColor,
                    height: 1.1,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (opacity >= 1) return badge;
    return Opacity(opacity: opacity, child: badge);
  }
}

class _PackageBadgeStyle {
  const _PackageBadgeStyle({
    required this.gradient,
    required this.textColor,
    required this.shadows,
  });

  final LinearGradient gradient;
  final Color textColor;
  final List<BoxShadow> shadows;

  static _PackageBadgeStyle forPackage(ListingPackage package) {
    return switch (package) {
      ListingPackage.standard => _PackageBadgeStyle(
          gradient: AppColors.packageFreeGradient,
          textColor: Colors.white,
          shadows: [
            BoxShadow(
              color: const Color(0xFF4A4A4E).withValues(alpha: 0.45),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ListingPackage.pro => _PackageBadgeStyle(
          gradient: AppColors.packageProGradient,
          textColor: Colors.white,
          shadows: [
            BoxShadow(
              color: const Color(0xFF48521C).withValues(alpha: 0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ListingPackage.premium => _PackageBadgeStyle(
          gradient: AppColors.packagePremiumGradient,
          textColor: Colors.white,
          shadows: [
            BoxShadow(
              color: const Color(0xFFC9921E).withValues(alpha: 0.45),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
    };
  }
}

class _SizeSpec {
  const _SizeSpec({
    required this.fontSize,
    required this.hPad,
    required this.vPad,
    required this.radius,
    required this.iconSize,
    required this.iconGap,
  });

  final double fontSize;
  final double hPad;
  final double vPad;
  final double radius;
  final double iconSize;
  final double iconGap;
}

_SizeSpec _sizeSpec(PackageBadgeSize size) {
  return switch (size) {
    PackageBadgeSize.compact => const _SizeSpec(
        fontSize: 9,
        hPad: 8,
        vPad: 3,
        radius: 12,
        iconSize: 10,
        iconGap: 2,
      ),
    PackageBadgeSize.medium => const _SizeSpec(
        fontSize: 11,
        hPad: 10,
        vPad: 4,
        radius: 14,
        iconSize: 12,
        iconGap: 3,
      ),
    PackageBadgeSize.large => const _SizeSpec(
        fontSize: 12,
        hPad: 12,
        vPad: 6,
        radius: 16,
        iconSize: 14,
        iconGap: 4,
      ),
  };
}
