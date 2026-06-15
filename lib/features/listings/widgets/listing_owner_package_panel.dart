import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/listing_model.dart';
import '../data/listings_repository.dart';
import '../providers/listing_detail_provider.dart';

/// Owner-only stats, expiry, and auto-renew for pro/premium listings.
class ListingOwnerPackagePanel extends ConsumerStatefulWidget {
  const ListingOwnerPackagePanel({super.key, required this.listing});

  final ListingModel listing;

  @override
  ConsumerState<ListingOwnerPackagePanel> createState() =>
      _ListingOwnerPackagePanelState();
}

class _ListingOwnerPackagePanelState
    extends ConsumerState<ListingOwnerPackagePanel> {
  late bool _autoRenew;

  @override
  void initState() {
    super.initState();
    _autoRenew = widget.listing.autoRenew;
  }

  @override
  void didUpdateWidget(covariant ListingOwnerPackagePanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listing.id != widget.listing.id ||
        oldWidget.listing.autoRenew != widget.listing.autoRenew) {
      _autoRenew = widget.listing.autoRenew;
    }
  }

  Future<void> _toggleAutoRenew(bool value) async {
    setState(() => _autoRenew = value);
    try {
      await ref.read(listingsRepositoryProvider).updateAutoRenew(
            listingId: widget.listing.id,
            autoRenew: value,
          );
      ref.invalidate(listingDetailProvider(widget.listing.id));
    } catch (_) {
      if (mounted) setState(() => _autoRenew = !value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    if (!listing.isProListing && !listing.isPremiumListing) {
      return const SizedBox.shrink();
    }

    final expiresAt = listing.expiresAt;
    final daysLeft = expiresAt?.difference(DateTime.now()).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.viewsCount}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'مشاهدة',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 36, color: AppColors.borderLight),
              Expanded(
                child: Column(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.contactCount}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      'تواصل',
                      style: GoogleFonts.tajawal(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.autorenew, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'التجديد التلقائي',
                  style: GoogleFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              CupertinoSwitch(
                value: _autoRenew,
                activeTrackColor: AppColors.primary,
                onChanged: _toggleAutoRenew,
              ),
            ],
          ),
        ),
        if (expiresAt != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              daysLeft != null && daysLeft > 0
                  ? 'ينتهي بعد $daysLeft يوم'
                  : 'منتهي الصلاحية',
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: daysLeft != null && daysLeft <= 3
                    ? Colors.red
                    : AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }
}
