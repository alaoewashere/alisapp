import '../../../core/utils/cached_network_image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../core/utils/listing_location_label.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../models/rating.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/listing_card_favorite_button.dart';
import '../../../shared/widgets/package_badge.dart';
import '../../../shared/widgets/verified_badge.dart';
import '../../../widgets/star_display.dart';

const _cardRadius = 16.0;
const _imageHeight = 130.0;

BoxDecoration listingCardDecoration() => BoxDecoration(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(_cardRadius),
      border: Border.all(
        color: AppColors.glassBorder,
        width: 1,
      ),
    );

String listingDaysAgoLabel(DateTime createdAt) {
  final days = DateTime.now().difference(createdAt).inDays;
  if (days <= 0) return 'اليوم';
  if (days == 1) return 'يوم واحد';
  return '${arabicNumber(days)} يوم';
}

String? listingCategoryLabel(ListingModel listing) {
  if (listing.categoryNameAr != null && listing.categoryNameAr!.isNotEmpty) {
    return listing.categoryNameAr;
  }
  return listing.conditionLabelAr;
}

/// Home grid listing card — white surface, image overlays, compact metadata.
class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing});

  final ListingModel listing;

  void _openDetail(BuildContext context) {
    HapticFeedback.selectionClick();
    context.push('/listing/${listing.id}');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSold = listing.displayStatus == ListingDisplayStatus.sold;
    final category = listingCategoryLabel(listing);
    final location = listingLocationLabel(listing);
    final daysLabel = listingDaysAgoLabel(listing.createdAt);

    return GestureDetector(
      onTap: () => _openDetail(context),
      onLongPress: () => _openDetail(context),
      child: RepaintBoundary(
        child: DecoratedBox(
        decoration: listingCardDecoration(),
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
                    _ListingImage(url: listing.coverImageUrl),
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
                            'مباع',
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
                        listing.formattedPrice,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: AppFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
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
