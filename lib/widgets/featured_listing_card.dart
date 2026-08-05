import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../core/l10n/l10n_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/cached_network_image_utils.dart';
import '../core/utils/listing_display_title.dart';
import '../shared/models/listing_model.dart';
import '../shared/widgets/listing_card_favorite_button.dart';
import '../shared/widgets/package_badge.dart';
import '../core/utils/navigation_guard.dart';

/// Compact gold-accent card for the home premium listings carousel.
class FeaturedListingCard extends ConsumerWidget {
  const FeaturedListingCard({super.key, required this.listing});

  final ListingModel listing;

  String? get _imageUrl {
    if (listing.coverImageUrl != null && listing.coverImageUrl!.isNotEmpty) {
      return listing.coverImageUrl;
    }
    if (listing.images.isNotEmpty) {
      return listing.images.first.url ?? listing.images.first.storagePath;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    return GestureDetector(
      onTap: () => context.pushGuarded('/listing/${listing.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.4),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 4 / 3,
                  child: _imageUrl != null
                      ? cachedListingImage(
                          context: context,
                          imageUrl: _imageUrl!,
                          width: 280,
                          height: 210,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: ListingFavoriteToggleButton(listing: listing),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: PackageBadge(
                    package: ListingPackage.premium,
                    size: PackageBadgeSize.compact,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 30,
                    child: Text(
                      listingDisplayTitle(listing),
                      style: AppFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      textDirection: TextDirection.rtl,
                      softWrap: true,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.formattedPriceFor(strings),
                    style: AppFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return ColoredBox(
      color: AppColors.primary.withValues(alpha: 0.12),
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.primary),
      ),
    );
  }
}
