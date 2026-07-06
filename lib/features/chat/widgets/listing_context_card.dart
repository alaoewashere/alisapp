import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

/// Inline listing preview shown in the message timeline at the point a
/// listing was actually shared — not a single banner frozen to whichever
/// listing started the conversation.
class ListingContextCard extends StatelessWidget {
  const ListingContextCard({
    super.key,
    required this.listingId,
    required this.title,
    this.imageUrl,
    this.price,
  });

  final String listingId;
  final String title;
  final String? imageUrl;
  final double? price;

  @override
  Widget build(BuildContext context) {
    final strings = context.l10n;
    final price = this.price;

    return GestureDetector(
      onTap: () => context.push('/listing/$listingId'),
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.fieldCarbon,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            _ListingThumb(url: imageUrl),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    title,
                    style: AppFonts.cairo(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textDirection: TextDirection.rtl,
                  ),
                  if (price != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      formatIQDWithL10n(price, strings),
                      style: AppFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                strings.listingBadge,
                style: AppFonts.cairo(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListingThumb extends StatelessWidget {
  const _ListingThumb({this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined, color: AppColors.primary),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        errorWidget: (_, _, _) => Container(
          width: 56,
          height: 56,
          color: AppColors.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.image_outlined, color: AppColors.primary),
        ),
      ),
    );
  }
}
