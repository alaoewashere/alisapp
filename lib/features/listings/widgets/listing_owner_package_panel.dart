import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../shared/widgets/package_badge.dart';
import '../../../shared/models/listing_model.dart';
import '../data/listings_repository.dart';
import '../providers/listing_detail_provider.dart';

/// Owner controls — package badge + auto-renew (pro/premium).
/// View / contact stats live in the advanced analytics panel above.
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
    if (widget.listing.isPendingModeration) return;
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
    final strings = ref.watch(appLocalizationsProvider);
    final listing = widget.listing;
    final pending = listing.isPendingModeration;
    final showRenew = listing.isProListing || listing.isPremiumListing;
    final expiresAt = listing.expiresAt;
    final daysLeft = expiresAt?.difference(DateTime.now()).inDays;

    final package =
        PackageBadge.packageForListing(listing) ?? ListingPackage.standard;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: PackageBadge(
            package: package,
            size: PackageBadgeSize.medium,
          ),
        ),
        if (pending) ...[
          const SizedBox(height: 10),
          _PendingStatsNotice(message: strings.listingPendingReviewStats),
        ],
        if (showRenew) ...[
          const SizedBox(height: 10),
          _AutoRenewCard(
            enabled: _autoRenew,
            pending: pending,
            subtitle: pending
                ? strings.autoRenewAfterApproval
                : expiresAt != null
                    ? (daysLeft != null && daysLeft > 0
                        ? strings.expiresInDays('$daysLeft')
                        : strings.statusExpired)
                    : null,
            isExpiringSoon: daysLeft != null && daysLeft <= 3,
            title: strings.autoRenewLabel,
            onChanged: pending ? null : _toggleAutoRenew,
          ),
        ],
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Pending-review hint shown above the owner controls.
class _PendingStatsNotice extends StatelessWidget {
  const _PendingStatsNotice({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pending.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.pending.withValues(alpha: 0.30)),
      ),
      child: Row(
        children: [
          Icon(Icons.hourglass_top_rounded, color: AppColors.pending, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppFonts.cairo(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Polished auto-renew control — icon chip, title, expiry subtitle, switch.
class _AutoRenewCard extends StatelessWidget {
  const _AutoRenewCard({
    required this.enabled,
    required this.pending,
    required this.title,
    required this.subtitle,
    required this.isExpiringSoon,
    required this.onChanged,
  });

  final bool enabled;
  final bool pending;
  final String title;
  final String? subtitle;
  final bool isExpiringSoon;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final accent = enabled ? AppColors.volt : AppColors.textMuted;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enabled
              ? AppColors.volt.withValues(alpha: 0.30)
              : AppColors.glassBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.autorenew_rounded, color: accent, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppFonts.cairo(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isExpiringSoon && !pending
                          ? AppColors.rejected
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          CupertinoSwitch(
            value: enabled,
            activeTrackColor: AppColors.volt,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
