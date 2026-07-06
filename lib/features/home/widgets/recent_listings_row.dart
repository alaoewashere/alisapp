import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/staggered_entrance.dart';
import 'listing_card.dart';

/// Horizontal scroll of recent listings on the home screen.
class RecentListingsRow extends StatelessWidget {
  const RecentListingsRow({super.key, required this.listings});

  static const cardWidth = 168.0;
  static const rowHeight = 248.0;

  final List<ListingModel> listings;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: listings.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return StaggeredEntrance(
            index: index,
            offset: 0.0,
            child: SizedBox(
              width: cardWidth,
              child: ListingCard(listing: listings[index]),
            ),
          );
        },
      ),
    );
  }
}

class RecentListingsRowShimmer extends StatelessWidget {
  const RecentListingsRowShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: RecentListingsRow.rowHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (_, _) => Container(
          width: RecentListingsRow.cardWidth,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
        ),
      ),
    );
  }
}
