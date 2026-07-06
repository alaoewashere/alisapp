import '../../../core/utils/cached_network_image_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/listing_display_l10n.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../core/utils/listing_location_label.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/premium_listing_badge.dart';
import '../../../shared/widgets/pro_listing_badge.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/guest_bottom_sheet.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../home/providers/home_provider.dart';

class ListingListTile extends ConsumerWidget {
  const ListingListTile({super.key, required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final isFavorite = ref.watch(
          toggleFavoriteProvider.select((ids) => ids.contains(listing.id)),
        ) ||
        listing.isFavorite;
    final isGuest = ref.watch(isGuestProvider);
    final conditionLabel = switch (listing.condition) {
      ListingCondition.newItem => strings.conditionNew,
      ListingCondition.used => strings.conditionUsed,
      _ => null,
    };

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
                  child: Stack(
                    fit: StackFit.expand,
                    clipBehavior: Clip.hardEdge,
                    children: [
                      if (listing.coverImageUrl != null)
                        cachedListingImage(
                          context: context,
                          imageUrl: listing.coverImageUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => Shimmer.fromColors(
                            baseColor: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            highlightColor:
                                Theme.of(context).colorScheme.surface,
                            child: const ColoredBox(color: Colors.white),
                          ),
                        )
                      else
                        ColoredBox(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest,
                          child: const Icon(Icons.image),
                        ),
                      if (listing.isPremiumListing)
                        const PremiumListingCardRibbon(),
                      if (listing.isProListing && !listing.isPremiumListing)
                        const Positioned(
                          top: 8,
                          right: 8,
                          child: ProListingCardBadge(),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listingDisplayTitle(listing),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listing.formattedPriceFor(strings),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      listingLocationLabel(listing),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    Text(
                      listing.timeAgoFor(localeCode),
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    if (conditionLabel != null) ...[
                      const SizedBox(height: 4),
                      _ConditionChip(label: conditionLabel),
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
