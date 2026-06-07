import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/listing_model.dart';
import '../../listings/data/listings_repository.dart';
import '../providers/profile_provider.dart';

class MyListingTile extends ConsumerWidget {
  const MyListingTile({
    super.key,
    required this.listing,
    required this.statusKey,
  });

  final ListingModel listing;
  final String statusKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final imageUrl = listing.coverImageUrl ??
        (listing.images.isNotEmpty
            ? (listing.images.first.url ?? listing.images.first.storagePath)
            : null);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (_, _, _) =>
                              const ColoredBox(color: Colors.black12),
                        )
                      : const ColoredBox(
                          color: Colors.black12,
                          child: Icon(Icons.image_not_supported),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.titleAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatIqd(listing.priceIqd),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${listing.timeAgo} · 👁 ${arabicNumber(listing.viewsCount)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _StatusChip(status: listing.displayStatus),
                  ],
                ),
              ),
              _ActionsColumn(listing: listing, statusKey: statusKey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final ListingDisplayStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      ListingDisplayStatus.active => AppColors.approved,
      ListingDisplayStatus.pending => AppColors.pending,
      ListingDisplayStatus.sold => Colors.blue,
      ListingDisplayStatus.deleted => AppColors.rejected,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(color: color, fontSize: 11),
      ),
    );
  }
}

class _ActionsColumn extends ConsumerWidget {
  const _ActionsColumn({required this.listing, required this.statusKey});

  final ListingModel listing;
  final String statusKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: switch (statusKey) {
        'active' => [
            _action(Icons.edit_outlined, 'تعديل', () {
              context.push('/listing/${listing.id}/edit');
            }),
            _action(Icons.check_circle_outline, 'مباع', () async {
              final ok = await _confirm(
                context,
                'تعليم كمباع',
                'هل تريد تعليم هذا الإعلان كمباع؟',
              );
              if (ok != true) return;
              await ref.read(listingsRepositoryProvider).markAsSold(listing.id);
              _refresh(ref);
            }),
            _action(Icons.delete_outline, 'حذف', () async {
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
            _action(Icons.rocket_launch_outlined, 'ترويج', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('قريباً')),
              );
            }),
          ],
        'sold' => [
            _action(Icons.replay, 'إعادة نشر', () async {
              final userId = ref.read(currentUserIdProvider);
              if (userId == null) return;
              try {
                final newId = await ref
                    .read(listingsRepositoryProvider)
                    .cloneListingForRepost(listing.id, userId);
                _refresh(ref);
                if (context.mounted) {
                  context.push('/listing/$newId/edit');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            }),
          ],
        'deleted' => [
            _action(Icons.restore, 'استعادة', () async {
              await ref
                  .read(listingsRepositoryProvider)
                  .restoreListing(listing.id);
              _refresh(ref);
            }),
          ],
        _ => <Widget>[],
      },
    );
  }

  Widget _action(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      visualDensity: VisualDensity.compact,
    );
  }

  Future<bool?> _confirm(
    BuildContext context,
    String title,
    String body,
  ) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _refresh(WidgetRef ref) {
    ref.invalidate(myListingsCountsProvider);
    for (final s in ['active', 'pending', 'sold', 'deleted']) {
      ref.invalidate(myListingsProvider(s));
    }
  }
}
