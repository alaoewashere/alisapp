import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/package_badge.dart';
import '../../../shared/models/listing_model.dart';
import '../data/listings_repository.dart';
import '../providers/listing_detail_provider.dart';

/// Owner insights — views, contacts, and auto-renew (pro/premium).
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
    final listing = widget.listing;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final pending = listing.isPendingModeration;
    final showRenew =
        listing.isProListing || listing.isPremiumListing;
    final expiresAt = listing.expiresAt;
    final daysLeft = expiresAt?.difference(DateTime.now()).inDays;

    final package = PackageBadge.packageForListing(listing) ??
        ListingPackage.standard;

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
        const SizedBox(height: 10),
        if (pending)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: scheme.outline.withValues(alpha: 0.35),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: scheme.onTertiaryContainer,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'إعلانك قيد المراجعة — الإحصائيات تُحدَّث تلقائياً بعد النشر',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onTertiaryContainer,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primaryContainer.withValues(alpha: 0.45),
                scheme.surfaceContainerHighest.withValues(alpha: 0.35),
              ],
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outlineVariant),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _InsightStat(
                    icon: Icons.visibility_rounded,
                    value: '${listing.viewsCount}',
                    label: 'مشاهدة',
                    iconColor: scheme.primary,
                  ),
                ),
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: scheme.outlineVariant,
                ),
                Expanded(
                  child: _InsightStat(
                    icon: Icons.forum_rounded,
                    value: '${listing.contactCount}',
                    label: 'تواصل',
                    iconColor: scheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showRenew)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(Icons.autorenew_rounded, color: scheme.primary, size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'التجديد التلقائي',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    CupertinoSwitch(
                      value: _autoRenew,
                      activeTrackColor: scheme.primary,
                      onChanged: pending ? null : _toggleAutoRenew,
                    ),
                  ],
                ),
                if (pending) ...[
                  const SizedBox(height: 6),
                  Text(
                    'يُفعَّل بعد موافقة الإدارة على الإعلان',
                    style: textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ] else if (expiresAt != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    daysLeft != null && daysLeft > 0
                        ? 'ينتهي بعد $daysLeft يوم'
                        : 'منتهي الصلاحية',
                    style: textTheme.bodySmall?.copyWith(
                      color: daysLeft != null && daysLeft <= 3
                          ? scheme.error
                          : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _InsightStat extends StatelessWidget {
  const _InsightStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
