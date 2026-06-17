import 'package:flutter/material.dart';

import '../models/listing_model.dart';
import 'package_badge.dart';

/// Compact pro pill for listing cards.
class ProListingCardBadge extends StatelessWidget {
  const ProListingCardBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackageBadge(
      package: ListingPackage.pro,
      size: PackageBadgeSize.compact,
    );
  }
}

/// Pro badge chip for listing detail info section.
class ProListingChip extends StatelessWidget {
  const ProListingChip({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackageBadge(
      package: ListingPackage.pro,
      size: PackageBadgeSize.medium,
    );
  }
}

/// Pro badge overlay on the listing detail photo hero.
class ProListingHeroBadge extends StatelessWidget {
  const ProListingHeroBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const PackageBadge(
      package: ListingPackage.pro,
      size: PackageBadgeSize.large,
    );
  }
}
