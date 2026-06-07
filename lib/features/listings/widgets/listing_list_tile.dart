import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../shared/models/listing_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/guest_bottom_sheet.dart';
import '../../home/providers/home_provider.dart';

class ListingListTile extends ConsumerWidget {
  const ListingListTile({super.key, required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overrides = ref.watch(favoriteOverridesProvider);
    final isFavorite = overrides[listing.id] ?? listing.isFavorite;
    final isGuest = ref.watch(isGuestProvider);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: listing.coverImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: listing.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            highlightColor: Theme.of(context).colorScheme.surface,
                            child: const ColoredBox(color: Colors.white),
                          ),
                        )
                      : ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.image),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.formattedPrice,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${governorateNameAr(listing.governorate)} · ${listing.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      listing.timeAgo,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (listing.conditionLabelAr != null) ...[
                      const SizedBox(height: 4),
                      _ConditionChip(label: listing.conditionLabelAr!),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  if (isGuest) {
                    await showGuestBottomSheet(context);
                    return;
                  }
                  await toggleListingFavorite(ref, listing);
                },
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConditionChip extends StatelessWidget {
  const _ConditionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}
