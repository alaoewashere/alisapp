import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/listing_model.dart';
import '../../auth/widgets/guest_bottom_sheet.dart';
import '../../auth/providers/auth_provider.dart';
import '../../favorites/providers/favorites_provider.dart';

class ListingCard extends ConsumerWidget {
  const ListingCard({super.key, required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteIds = ref.watch(toggleFavoriteProvider);
    final isFavorite = favoriteIds.contains(listing.id) || listing.isFavorite;
    final isGuest = ref.watch(isGuestProvider);
    final isSold = listing.displayStatus == ListingDisplayStatus.sold;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: InkWell(
        onTap: () => context.push('/listing/${listing.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ListingImage(url: listing.coverImageUrl),
                  if (listing.isBoosted || listing.isFeatured)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مميز',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isSold)
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'مباع',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: const CircleBorder(),
                      child: IconButton(
                        visualDensity: VisualDensity.compact,
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        onPressed: () async {
                          if (isGuest || !ref.read(isAuthenticatedProvider)) {
                            await showGuestBottomSheet(context);
                            return;
                          }
                          await ref
                              .read(toggleFavoriteProvider.notifier)
                              .toggle(listing.id);
                        },
                        icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      listing.titleAr,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
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
                    if (listing.isNegotiable) ...[
                      const SizedBox(height: 2),
                      Text(
                        'قابل للتفاوض',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                    const Spacer(),
                    Text(
                      '${governorateNameAr(listing.governorate)} · ${listing.city}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                    Text(
                      listing.timeAgo,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    if (url == null) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.image, size: 40),
      );
    }

    return CachedNetworkImage(
      imageUrl: url!,
      fit: BoxFit.cover,
      placeholder: (_, _) => Shimmer.fromColors(
        baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
        highlightColor: Theme.of(context).colorScheme.surface,
        child: const ColoredBox(color: Colors.white),
      ),
      errorWidget: (_, _, _) => ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.broken_image_outlined),
      ),
    );
  }
}
