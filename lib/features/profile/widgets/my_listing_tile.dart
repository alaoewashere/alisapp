import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../shared/models/listing_model.dart';
import '../../listings/data/listings_repository.dart';
import '../../home/providers/home_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/user_subscription_tier_provider.dart';
import '../utils/listing_boost_utils.dart';
import 'listing_boost_sheet.dart';

class MyListingTile extends ConsumerWidget {
  const MyListingTile({
    super.key,
    required this.listing,
    required this.statusKey,
  });

  final ListingModel listing;
  final String statusKey;

  static const _thumbSize = 70.0;
  static const _cardRadius = 14.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = listing.coverImageUrl ??
        (listing.images.isNotEmpty
            ? (listing.images.first.url ?? listing.images.first.storagePath)
            : null);

    final userTierAsync = ref.watch(userSubscriptionTierProvider);
    final showBoost = statusKey == 'active' &&
        userTierAsync.maybeWhen(
          data: (tier) => isListingBoostEligible(
            listing: listing,
            userTier: tier,
          ),
          orElse: () => false,
        );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(_cardRadius),
        border: Border.all(color: const Color(0x15FFFFFF)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/listing/${listing.id}'),
          borderRadius: BorderRadius.circular(_cardRadius),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              textDirection: TextDirection.rtl,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    width: _thumbSize,
                    height: _thumbSize,
                    child: imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                const _ThumbPlaceholder(),
                          )
                        : const _ThumbPlaceholder(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        listingDisplayTitle(listing),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pureWhite,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatIqd(listing.priceIqd),
                        style: AppFonts.cairo(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.volt,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _StatusPill(status: listing.displayStatus),
                      const SizedBox(height: 6),
                      Text(
                        '👁 ${arabicNumber(listing.viewsCount)} · ${listing.timeAgo}',
                        style: AppFonts.cairo(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                _ActionsRow(
                  listing: listing,
                  statusKey: statusKey,
                  showBoost: showBoost,
                  onBoost: () {
                    final tier = userTierAsync.value;
                    if (tier == null) return;
                    showListingBoostSheet(
                      context,
                      ref,
                      listing: listing,
                      userTier: tier,
                      onSuccess: () => _refresh(ref),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(myListingsCountsProvider);
    ref.invalidate(userSubscriptionTierProvider);
    for (final s in ['active', 'pending', 'sold', 'deleted']) {
      ref.invalidate(myListingsProvider(s));
    }
    ref.invalidate(latestHomeListingsProvider);
    ref.invalidate(featuredListingsProvider);
  }
}

class _ThumbPlaceholder extends StatelessWidget {
  const _ThumbPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: AppColors.canvas,
      child: Icon(Icons.image_not_supported, color: AppColors.textMuted),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ListingDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final isActive = status == ListingDisplayStatus.active;

    if (isActive) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.volt,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status.labelAr,
          style: AppFonts.cairo(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.canvas,
          ),
        ),
      );
    }

    final color = switch (status) {
      ListingDisplayStatus.pending => AppColors.pending,
      ListingDisplayStatus.sold => Colors.blue,
      ListingDisplayStatus.deleted => AppColors.rejected,
      ListingDisplayStatus.active => AppColors.volt,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.labelAr,
        style: AppFonts.cairo(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _ActionsRow extends ConsumerWidget {
  const _ActionsRow({
    required this.listing,
    required this.statusKey,
    required this.showBoost,
    required this.onBoost,
  });

  final ListingModel listing;
  final String statusKey;
  final bool showBoost;
  final VoidCallback onBoost;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = <_ActionSpec>[];

    if (statusKey == 'active') {
      actions.addAll([
        _ActionSpec(Icons.edit_outlined, 'تعديل', () {
          context.push(AppRoutes.editListingPath(listing.id));
        }),
        _ActionSpec(Icons.check_rounded, 'مباع', () async {
          final ok = await _confirm(
            context,
            'تعليم كمباع',
            'هل تريد تعليم هذا الإعلان كمباع؟',
          );
          if (ok != true) return;
          await ref.read(listingsRepositoryProvider).markAsSold(listing.id);
          _refresh(ref);
        }),
        _ActionSpec(Icons.delete_outline, 'حذف', () async {
          final ok = await _confirm(
            context,
            'حذف الإعلان',
            'هل تريد حذف هذا الإعلان؟',
          );
          if (ok != true) return;
          await ref
              .read(listingsRepositoryProvider)
              .softDeleteListing(listing.id);
          _refresh(ref);
        }),
      ]);
      if (showBoost) {
        actions.add(
          _ActionSpec(Icons.rocket_launch_outlined, 'ترويج', onBoost),
        );
      }
    } else if (statusKey == 'sold') {
      actions.add(
        _ActionSpec(Icons.replay, 'إعادة نشر', () async {
          final userId = ref.read(currentUserIdProvider);
          if (userId == null) return;
          try {
            final newId = await ref
                .read(listingsRepositoryProvider)
                .cloneListingForRepost(listing.id, userId);
            _refresh(ref);
            if (context.mounted) {
              context.push(AppRoutes.editListingPath(newId));
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$e')),
              );
            }
          }
        }),
      );
    } else if (statusKey == 'deleted') {
      actions.add(
        _ActionSpec(Icons.restore, 'استعادة', () async {
          await ref
              .read(listingsRepositoryProvider)
              .restoreListing(listing.id);
          _refresh(ref);
        }),
      );
    }

    if (actions.isEmpty) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          _ActionIconButton(spec: actions[i]),
          if (i < actions.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(myListingsCountsProvider);
    for (final s in ['active', 'pending', 'sold', 'deleted']) {
      ref.invalidate(myListingsProvider(s));
    }
  }

  Future<bool?> _confirm(BuildContext context, String title, String body) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }
}

class _ActionSpec {
  const _ActionSpec(this.icon, this.tooltip, this.onTap);

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({required this.spec});

  final _ActionSpec spec;

  static const _size = 36.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: spec.onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: spec.tooltip,
          child: SizedBox(
            width: _size,
            height: _size,
            child: Icon(
              spec.icon,
              size: 18,
              color: AppColors.pureWhite,
            ),
          ),
        ),
      ),
    );
  }
}
