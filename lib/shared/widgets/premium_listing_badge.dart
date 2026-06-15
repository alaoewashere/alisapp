import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Diagonal gold ribbon for premium listings on card thumbnails.
class PremiumListingCardRibbon extends StatelessWidget {
  const PremiumListingCardRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      right: -28,
      child: Transform.rotate(
        angle: 0.78539816339,
        child: Container(
          width: 110,
          height: 26,
          decoration: BoxDecoration(
            gradient: AppColors.listingPremiumGoldGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.premiumGold.withValues(alpha: 0.4),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '★  مميز',
            style: AppTextStyles.subheading.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

/// Gold badge overlay on the listing detail photo hero.
class PremiumListingHeroBadge extends StatelessWidget {
  const PremiumListingHeroBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: AppColors.listingPremiumGoldGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.premiumGold.withValues(alpha: 0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            'إعلان مميز',
            style: AppTextStyles.subheading.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Gold chip for the listing info tab badge row.
class PremiumListingChip extends StatelessWidget {
  const PremiumListingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: AppColors.listingPremiumGoldGradient,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 12),
          const SizedBox(width: 3),
          Text(
            'مميز',
            style: AppTextStyles.subheading.copyWith(
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
