import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../shared/models/listing_model.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../listings/data/listings_repository.dart';

class FeaturedBanner extends ConsumerStatefulWidget {
  const FeaturedBanner({super.key, required this.listings});

  final List<ListingModel> listings;

  @override
  ConsumerState<FeaturedBanner> createState() => _FeaturedBannerState();
}

class _FeaturedBannerState extends ConsumerState<FeaturedBanner> {
  late final PageController _controller;
  Timer? _timer;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController();
    if (widget.listings.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted || !_controller.hasClients) return;
        _current = (_current + 1) % widget.listings.length;
        _controller.animateToPage(
          _current,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.listings.isEmpty) return const SizedBox.shrink();

    final items = widget.listings.take(3).toList();

    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: _controller,
        itemCount: items.length,
        onPageChanged: (i) => _current = i,
        itemBuilder: (context, index) {
          final listing = items[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FeaturedBannerCard(listing: listing),
          );
        },
      ),
    );
  }
}

class _FeaturedBannerCard extends ConsumerWidget {
  const _FeaturedBannerCard({required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          ref.read(listingsRepositoryProvider).incrementViews(listing.id);
          context.push('/listing/${listing.id}');
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (listing.coverImageUrl != null)
              CachedNetworkImage(
                imageUrl: listing.coverImageUrl!,
                fit: BoxFit.cover,
                placeholder: (_, _) => Shimmer.fromColors(
                  baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  highlightColor: Theme.of(context).colorScheme.surface,
                  child: const ColoredBox(color: Colors.white),
                ),
                errorWidget: (_, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_not_supported, size: 48),
                ),
              )
            else
              ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.image, size: 48),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.7),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'مميز',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.titleAr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    listing.formattedPrice,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeaturedBannerShimmer extends StatelessWidget {
  const FeaturedBannerShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ShimmerBox(
        width: double.infinity,
        height: 180,
        borderRadius: 16,
      ),
    );
  }
}
