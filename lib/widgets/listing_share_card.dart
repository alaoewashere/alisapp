import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../l10n/app_localizations.dart';
import '../core/l10n/l10n_provider.dart';
import '../core/constants/app_colors.dart';
import '../shared/widgets/app_logo.dart';
import '../core/constants/app_governorates.dart';
import '../core/constants/deep_link_constants.dart';
import '../core/utils/arabic_number.dart';
import '../core/utils/currency_formatter.dart';
import '../core/utils/listing_display_title.dart';
import '../services/share_service.dart';
import '../shared/models/listing_model.dart';
import 'sello_watermark.dart';

/// Off-screen 1080×1350 share card captured via [repaintKey].
class ListingShareCard extends StatelessWidget {
  const ListingShareCard({
    super.key,
    required this.repaintKey,
    required this.listing,
    this.imageReady = true,
  });

  final GlobalKey repaintKey;
  final ListingModel listing;
  final bool imageReady;

  static const cardWidth = 1080.0;
  static const cardHeight = 1350.0;

  String get _locationLabel {
    if (listing.locationAddress?.trim().isNotEmpty == true) {
      return listing.locationAddress!.trim();
    }
    if (listing.city.trim().isNotEmpty) return listing.city.trim();
    return governorateNameAr(listing.governorate);
  }

  String _referenceLabel(AppLocalizations strings) {
    if (listing.referenceNo != null) {
      return strings.listingNumberWithRef(arabicNumber(listing.referenceNo!));
    }
    return strings.listingNumberDash;
  }

  String? get _deepLinkLabel {
    if (listing.referenceNo != null) {
      return DeepLinkConstants.listingUrl(listing.referenceNo!);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final imageUrl = listingShareImageUrl(listing);

    return RepaintBoundary(
      key: repaintKey,
      child: SizedBox(
        width: cardWidth,
        height: cardHeight,
        child: ColoredBox(
          color: Colors.white,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: cardHeight * 0.55,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        if (imageUrl != null && imageReady)
                          CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, _) => const _PhotoPlaceholder(),
                            errorWidget: (_, _, _) => const _PhotoPlaceholder(),
                          )
                        else
                          const _PhotoPlaceholder(),
                        DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.85),
                              ],
                              stops: const [0.45, 1.0],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 32,
                          right: 32,
                          bottom: 28,
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  listingDisplayTitle(listing),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                  style: AppFonts.cairo(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    height: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formatIQDWithL10n(listing.price, strings),
                                  textAlign: TextAlign.right,
                                  style: AppFonts.inter(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'sello.iq',
                                  style: AppFonts.inter(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const AppLogo(size: 40),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Text(
                                    _locationLabel,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppFonts.cairo(
                                      fontSize: 16,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 18,
                                  color: AppColors.textMuted,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _referenceLabel(strings),
                              textAlign: TextAlign.right,
                              style: AppFonts.cairo(
                                fontSize: 13,
                                color: AppColors.textMuted.withValues(alpha: 0.85),
                              ),
                            ),
                            if (_deepLinkLabel != null) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppColors.primary.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Text(
                                    _deepLinkLabel!,
                                    style: AppFonts.robotoMono(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                            const Spacer(),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 28,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Text(
                                  strings.contactUsOnSouqak,
                                  style: AppFonts.cairo(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SelloWatermark(
                size: const Size(cardWidth, cardHeight),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.borderLight,
      child: Icon(
        Icons.image_outlined,
        size: 120,
        color: AppColors.textMuted.withValues(alpha: 0.5),
      ),
    );
  }
}
