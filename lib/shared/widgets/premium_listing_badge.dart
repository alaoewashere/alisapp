import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import 'package_badge.dart';

/// Compact premium pill on listing card thumbnails.
class PremiumListingCardRibbon extends StatelessWidget {
  const PremiumListingCardRibbon({super.key});

  @override
  Widget build(BuildContext context) {
    return const Positioned(
      top: 8,
      right: 8,
      child: PackageBadge(
        package: ListingPackage.premium,
        size: PackageBadgeSize.compact,
      ),
    );
  }
}

/// Premium badge overlay on the listing detail photo hero.
class PremiumListingHeroBadge extends StatelessWidget {
  const PremiumListingHeroBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackageBadge(
      package: ListingPackage.premium,
      size: PackageBadgeSize.large,
    );
  }
}

/// Premium chip for the listing info tab badge row.
class PremiumListingChip extends StatelessWidget {
  const PremiumListingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackageBadge(
      package: ListingPackage.premium,
      size: PackageBadgeSize.medium,
    );
  }
}
