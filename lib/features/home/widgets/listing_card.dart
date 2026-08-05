import '../../../core/utils/cached_network_image_utils.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/pressable_scale.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/l10n/listing_display_l10n.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../core/utils/listing_location_label.dart';
import '../../../models/rating.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/listing_card_favorite_button.dart';
import '../../../shared/widgets/package_badge.dart';
import '../../../shared/widgets/verified_badge.dart';
import '../../../widgets/star_display.dart';
import '../../../core/utils/navigation_guard.dart';

const _cardRadius = 16.0;
const _imageHeight = 130.0;

BoxDecoration listingCardDecoration([ListingPackage? package]) {
  final (borderColor, borderWidth, shadow) = switch (package) {
    ListingPackage.pro => (
        const Color(0xFF999F54),
        1.5,
        [
          BoxShadow(
            color: const Color(0xFF999F54).withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    ListingPackage.premium => (
        AppColors.premiumGold,
        1.5,
        [
          BoxShadow(
            color: AppColors.premiumGold.withValues(alpha: 0.22),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    _ => (AppColors.glassBorder, 1.0, <BoxShadow>[]),
  };
  return BoxDecoration(
    color: AppColors.fieldCarbon,
    borderRadius: BorderRadius.circular(_cardRadius),
    border: Border.all(color: borderColor, width: borderWidth),
    boxShadow: shadow,
  );
}

String listingDaysAgoLabel(DateTime createdAt, AppLocalizations strings) {
  final days = DateTime.now().difference(createdAt).inDays;
  if (days <= 0) return strings.listingPostedToday;
  if (days == 1) return strings.listingPostedOneDayAgo;
  return strings.listingPostedDaysAgo('$days');
}

String? listingCategoryLabel(ListingModel listing, AppLocalizations strings) {
  final breadcrumb = listing.categoryBreadcrumbFor(strings);
  if (breadcrumb.isNotEmpty) return breadcrumb;
  return listing.conditionLabelFor(strings);
}

/// Home grid listing card — white surface, image overlays, compact metadata.
class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing});

  final ListingModel listing;

  void _openDetail(BuildContext context) {
    context.pushGuarded('/listing/${listing.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final isSold = listing.displayStatus == ListingDisplayStatus.sold;
    final category = listingCategoryLabel(listing, strings);
    final location = listingLocationLabel(listing);
    final daysLabel = listingDaysAgoLabel(listing.createdAt, strings);

    return PressableScale(
      onTap: () => _openDetail(context),
      onLongPress: () => _openDetail(context),
      child: RepaintBoundary(
        child: DecoratedBox(
        decoration: listingCardDecoration(
          listing.isPremiumListing
              ? ListingPackage.premium
              : listing.isProListing
                  ? ListingPackage.pro
                  : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: _imageHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Hero(
                      tag: 'listing-image-${listing.id}',
                      child: _ListingImage(url: listing.coverImageUrl),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: ListingFavoriteToggleButton(listing: listing),
                    ),
                    if (shouldShowSellerRatingBadge(
                      avgRating: listing.sellerAvgRating,
                      ratingCount: listing.sellerRatingCount,
                    ))
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: SellerRatingBadge(
                          avgRating: listing.sellerAvgRating,
                        ),
                      )
                    else if (listing.sellerIsVerified)
                      const Positioned(
                        bottom: 8,
                        left: 8,
                        child: VerifiedBadge(size: 16),
                      ),
                    if (listing.referenceNo != null)
                      Positioned(
                        bottom: 8,
                        right: 8,
                        child: _DarkImagePill(
                          label: '#${listing.referenceNo}',
                        ),
                      ),
                    if (listing.isPremiumListing)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: PackageBadge(
                          package: ListingPackage.premium,
                          size: PackageBadgeSize.compact,
                        ),
                      )
                    else if (listing.isProListing)
                      const Positioned(
                        top: 8,
                        right: 8,
                        child: PackageBadge(
                          package: ListingPackage.pro,
                          size: PackageBadgeSize.compact,
                        ),
                      ),
                    if (isSold)
                      Container(
                        color: Colors.black45,
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            strings.sold,
                            style: AppFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 6, 10, 2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (category != null) ...[
                        Align(
                          alignment: Alignment.centerRight,
                          child: _GreenCategoryPill(label: category),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        listingDisplayTitle(listing),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppFonts.cairo(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        listing.formattedPriceFor(strings),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppFonts.inter(
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.volt,
                          height: 1.2,
                        ),
                      ),
                      if (formatUsdApprox(listing.price).isNotEmpty)
                        Text(
                          formatUsdApprox(listing.price),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.ltr,
                          style: AppFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            height: 1.2,
                          ),
                        ),
                      const Spacer(),
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 11,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(width: 3),
                                Expanded(
                                  child: Text(
                                    location,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.right,
                                    style: AppFonts.cairo(
                                      fontSize: 10,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            daysLabel,
                            style: AppFonts.cairo(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _DarkImagePill extends StatelessWidget {
  const _DarkImagePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppFonts.cairo(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GreenCategoryPill extends StatelessWidget {
  const _GreenCategoryPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppFonts.cairo(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _ListingImage extends StatelessWidget {
  const _ListingImage({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return const ColoredBox(
        color: AppColors.borderLight,
        child: Icon(Icons.image_outlined, size: 36, color: AppColors.textMuted),
      );
    }

    return cachedListingImage(
      context: context,
      imageUrl: url!,
      width: 200,
      height: _imageHeight,
      fit: BoxFit.cover,
      placeholder: (_, _) => Shimmer.fromColors(
        baseColor: AppColors.borderLight,
        highlightColor: Colors.white,
        child: const ColoredBox(color: Colors.white),
      ),
      errorWidget: (_, _, _) => const ColoredBox(
        color: AppColors.borderLight,
        child: Icon(Icons.broken_image_outlined, color: AppColors.textMuted),
      ),
    );
  }
}
