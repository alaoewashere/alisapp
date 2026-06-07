import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

import '../../../shared/models/listing_model.dart';

class ListingDetailGallery extends StatefulWidget {
  const ListingDetailGallery({
    super.key,
    required this.listing,
    required this.onBack,
    required this.onShare,
    required this.onFavorite,
    required this.favoriteLoading,
  });

  final ListingModel listing;
  final VoidCallback onBack;
  final VoidCallback onShare;
  final VoidCallback onFavorite;
  final bool favoriteLoading;

  @override
  State<ListingDetailGallery> createState() => _ListingDetailGalleryState();
}

class _ListingDetailGalleryState extends State<ListingDetailGallery> {
  late final PageController _pageController;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _preloadAround(0));
  }

  void _preloadAround(int index) {
    if (!mounted) return;
    final urls = _urls;
    for (final i in [index - 1, index, index + 1]) {
      if (i >= 0 && i < urls.length) {
        precacheImage(CachedNetworkImageProvider(urls[i]), context);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<String> get _urls {
    if (widget.listing.images.isNotEmpty) {
      return widget.listing.images
          .map((i) => i.url ?? i.storagePath)
          .where((u) => u.isNotEmpty)
          .toList();
    }
    if (widget.listing.coverImageUrl != null) {
      return [widget.listing.coverImageUrl!];
    }
    return [];
  }

  void _openZoom(int initialIndex) {
    final urls = _urls;
    if (urls.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ZoomGallery(urls: urls, initialIndex: initialIndex),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final urls = _urls;
    final count = urls.length;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (count == 0)
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.image, size: 64),
          )
        else
          PageView.builder(
            controller: _pageController,
            allowImplicitScrolling: true,
            itemCount: count,
            onPageChanged: (i) {
              setState(() => _index = i);
              _preloadAround(i);
            },
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _openZoom(i),
              child: CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                placeholder: (_, _) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (_, _, _) => const Icon(Icons.broken_image),
              ),
            ),
          ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          right: 8,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.onBack,
            icon: const Icon(Icons.arrow_back),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 8,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.onShare,
            icon: const Icon(Icons.share_outlined),
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 56,
          child: IconButton.filled(
            style: IconButton.styleFrom(
              backgroundColor: Colors.black45,
              foregroundColor: Colors.white,
            ),
            onPressed: widget.favoriteLoading ? null : widget.onFavorite,
            icon: widget.favoriteLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    widget.listing.isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        widget.listing.isFavorite ? Colors.red : Colors.white,
                  ),
          ),
        ),
        if (count > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_index + 1}/$count',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
      ],
    );
  }
}

class _ZoomGallery extends StatefulWidget {
  const _ZoomGallery({required this.urls, required this.initialIndex});

  final List<String> urls;
  final int initialIndex;

  @override
  State<_ZoomGallery> createState() => _ZoomGalleryState();
}

class _ZoomGalleryState extends State<_ZoomGallery> {
  late final PageController _controller;
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_index + 1}/${widget.urls.length}'),
      ),
      body: PhotoViewGallery.builder(
        pageController: _controller,
        itemCount: widget.urls.length,
        onPageChanged: (i) => setState(() => _index = i),
        builder: (_, i) => PhotoViewGalleryPageOptions(
          imageProvider: CachedNetworkImageProvider(widget.urls[i]),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
        ),
      ),
    );
  }
}
