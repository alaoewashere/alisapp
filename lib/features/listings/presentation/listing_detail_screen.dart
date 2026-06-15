import '../../../widgets/user_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/display_locale.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../core/utils/listing_publication_date.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/widgets/guest_bottom_sheet.dart';
import '../../../core/utils/share_listing.dart';
import '../../../services/rating_service.dart';
import '../../../services/share_service.dart';
import '../../../shared/models/listing_model.dart';
import '../../../widgets/listing_share_card.dart';
import '../../../widgets/listing_video_player.dart';
import '../../../widgets/rate_dialog.dart';
import '../../../widgets/star_display.dart';
import '../../../shared/widgets/verified_badge.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../favorites/data/favorites_repository.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/listing_detail_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_detail_bottom_bar.dart';
import '../widgets/listing_detail_gallery.dart';
import '../widgets/report_sheet.dart';
import '../../../core/utils/listing_metadata_detail_rows.dart';
import '../widgets/listing_metadata_detail_section.dart';
import '../widgets/car_paint/car_paint_summary_widget.dart';
import '../../../widgets/price_history_widget.dart';
import '../widgets/vehicle_stats_row.dart';
import '../../../shared/widgets/premium_listing_badge.dart';
import '../../../shared/widgets/pro_listing_badge.dart';
import '../../../theme/app_text_styles.dart';

class ListingDetailScreen extends ConsumerWidget {
  const ListingDetailScreen({
    super.key,
    this.listingId,
    this.referenceNo,
  }) : assert(
          listingId != null || referenceNo != null,
          'Provide listingId or referenceNo',
        );

  final String? listingId;
  final int? referenceNo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingAsync = referenceNo != null
        ? ref.watch(listingDetailByReferenceProvider(referenceNo!))
        : ref.watch(listingDetailProvider(listingId!));

    final resolvedId = listingId ?? listingAsync.value?.id ?? '';
    final favoriteLoadingId = ref.watch(listingFavoriteLoadingProvider);
    final isOwner = resolvedId.isNotEmpty
        ? ref.watch(isOwnerProvider(resolvedId))
        : false;

    return listingAsync.when(
      loading: () => const Scaffold(
        body: LoadingWidget(message: 'جاري التحميل...'),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorWidget(
          message: '$e',
          onRetry: () {
          if (referenceNo != null) {
            ref.invalidate(listingDetailByReferenceProvider(referenceNo!));
          } else {
            ref.invalidate(listingDetailProvider(listingId!));
          }
        },
        ),
      ),
      data: (listing) {
        if (listing == null) {
          return Scaffold(
            appBar: AppBar(),
            body: AppErrorWidget(
              message: 'الإعلان غير موجود',
              onRetry: () {
          if (referenceNo != null) {
            ref.invalidate(listingDetailByReferenceProvider(referenceNo!));
          } else {
            ref.invalidate(listingDetailProvider(listingId!));
          }
        },
            ),
          );
        }

        return _ListingDetailLoadedView(
          listing: listing,
          isOwner: isOwner,
          listingId: listing.id,
          favoriteLoadingId: favoriteLoadingId,
          onToggleFavorite: () => _toggleFavorite(context, ref, listing),
        );
      },
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    ListingModel listing,
  ) async {
    if (ref.read(isGuestProvider)) {
      await showGuestBottomSheet(context);
      return;
    }
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }
    ref.read(listingFavoriteLoadingProvider.notifier).setListingId(listing.id);
    try {
      await ref.read(favoritesRepositoryProvider).toggle(userId, listing.id);
      if (referenceNo != null) {
        ref.invalidate(listingDetailByReferenceProvider(referenceNo!));
      } else {
        ref.invalidate(listingDetailProvider(listingId!));
      }
      ref.invalidate(favoritesProvider);
    } finally {
      ref.read(listingFavoriteLoadingProvider.notifier).setListingId(null);
    }
  }
}

class _ListingDetailLoadedView extends ConsumerStatefulWidget {
  const _ListingDetailLoadedView({
    required this.listing,
    required this.isOwner,
    required this.listingId,
    required this.favoriteLoadingId,
    required this.onToggleFavorite,
  });

  final ListingModel listing;
  final bool isOwner;
  final String listingId;
  final String? favoriteLoadingId;
  final VoidCallback onToggleFavorite;

  @override
  ConsumerState<_ListingDetailLoadedView> createState() =>
      _ListingDetailLoadedViewState();
}

class _ListingDetailLoadedViewState
    extends ConsumerState<_ListingDetailLoadedView> {
  final GlobalKey _shareRepaintKey = GlobalKey();
  bool _shareImageReady = false;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _precacheShareImage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptBuyerRating());
  }

  Future<void> _maybePromptBuyerRating() async {
    final listing = widget.listing;
    if (widget.isOwner) return;
    if (listing.displayStatus != ListingDisplayStatus.sold) return;

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final alreadyRated =
        await ref.read(ratingServiceProvider).hasRated(listing.id);
    if (alreadyRated || !mounted) return;

    await showRateDialog(
      context: context,
      ref: ref,
      listingId: listing.id,
      reviewedId: listing.userId,
      reviewedName: listing.sellerName ?? 'البائع',
      reviewedAvatarSeed: listing.sellerAvatarSeed,
      subtitle: 'قيّم البائع',
    );
  }

  Future<void> _precacheShareImage() async {
    final url = listingShareImageUrl(widget.listing);
    if (url == null) {
      if (mounted) setState(() => _shareImageReady = true);
      return;
    }

    try {
      await precacheImage(CachedNetworkImageProvider(url), context);
    } catch (_) {
      // Placeholder is shown if precache fails.
    }

    if (mounted) setState(() => _shareImageReady = true);
  }

  Future<void> _shareListingToWhatsApp() async {
    if (_sharing || !_shareImageReady) return;

    setState(() => _sharing = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      await WidgetsBinding.instance.endOfFrame;
      await ShareService.shareListingToWhatsApp(
        repaintKey: _shareRepaintKey,
        listing: widget.listing,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذّر إنشاء البطاقة، حاول مرة أخرى'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                automaticallyImplyLeading: false,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    final settings = context
                        .dependOnInheritedWidgetOfExactType<
                            FlexibleSpaceBarSettings>();
                    final collapsed = settings == null ||
                        settings.currentExtent <= settings.minExtent + 10;
                    return collapsed
                        ? Text(
                            listingDisplayTitle(listing),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : const SizedBox.shrink();
                  },
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: ListingDetailGallery(
                    listing: listing,
                    favoriteLoading:
                        widget.favoriteLoadingId == widget.listingId,
                    onBack: () => context.canPop()
                        ? context.pop()
                        : context.go(AppRoutes.home),
                    onShare: () => shareListingUrl(listing),
                    onFavorite: widget.onToggleFavorite,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _ListingDetailBody(
                  listing: listing,
                  isOwner: widget.isOwner,
                ),
              ),
            ],
          ),
          bottomNavigationBar: ListingDetailBottomBar(
            listing: listing,
            isOwner: widget.isOwner,
            onShareWhatsApp: _shareListingToWhatsApp,
            shareEnabled: _shareImageReady && !_sharing,
          ),
        ),
        if (_sharing)
          Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        Positioned(
          left: -10000,
          top: 0,
          child: ListingShareCard(
            repaintKey: _shareRepaintKey,
            listing: listing,
            imageReady: _shareImageReady,
          ),
        ),
      ],
    );
  }
}

class _ListingDetailBody extends ConsumerStatefulWidget {
  const _ListingDetailBody({
    required this.listing,
    required this.isOwner,
  });

  final ListingModel listing;
  final bool isOwner;

  @override
  ConsumerState<_ListingDetailBody> createState() => _ListingDetailBodyState();
}

class _ListingDetailBodyState extends ConsumerState<_ListingDetailBody>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final listing = widget.listing;
    final isOwner = widget.isOwner;
    final sellerKey = (
      sellerId: listing.userId,
      excludeListingId: listing.id,
    );
    final otherListingsAsync = ref.watch(sellerOtherListingsProvider(sellerKey));
    final sellerCountAsync = ref.watch(sellerListingsCountProvider(listing.userId));
    final metadataDisplay = buildListingMetadataDisplay(listing);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'إعلان'),
              Tab(text: 'الوصف'),
              Tab(text: 'الموقع'),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              switch (_tabController.index) {
                case 1:
                  return _ListingDescriptionTab(listing: listing);
                case 2:
                  return _ListingLocationTab(listing: listing);
                case 0:
                default:
                  return _ListingInfoTab(
                    listing: listing,
                    metadataDisplay: metadataDisplay,
                    isTabActive: _tabController.index == 0,
                  );
              }
            },
          ),
          const Divider(height: 32),
          _SellerCard(
            listing: listing,
            listingsCount: sellerCountAsync.value ?? 0,
          ),
          const SizedBox(height: 16),
          otherListingsAsync.when(
            data: (items) {
              if (items.isEmpty) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'إعلانات أخرى للبائع',
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(
                          '/seller/${listing.userId}',
                        ),
                        child: const Text('عرض الكل'),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (_, i) => SizedBox(
                        width: 160,
                        child: ListingCard(listing: items[i]),
                      ),
                    ),
                  ),
                ],
              );
            },
            loading: () => const SizedBox(
              height: 40,
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
          const _SafetyTipsSection(),
          const SizedBox(height: 8),
          if (!isOwner)
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReportSheet(listingId: listing.id),
              ),
              child: Text(
                'الإبلاغ عن هذا الإعلان',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label, this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Theme.of(context).colorScheme.secondaryContainer)
            .withValues(alpha: color != null ? 0.15 : 1),
        borderRadius: BorderRadius.circular(16),
        border: color != null ? Border.all(color: color!) : null,
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.outline),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ListingInfoTab extends StatelessWidget {
  const _ListingInfoTab({
    required this.listing,
    required this.metadataDisplay,
    this.isTabActive = true,
  });

  final ListingModel listing;
  final ListingMetadataDisplay metadataDisplay;
  final bool isTabActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (listing.hasListingVideo) ...[
          Text(
            '🎥 جولة بالفيديو',
            style: GoogleFonts.cairo(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          ListingVideoPlayer(
            videoUrl: listing.videoUrl!,
            thumbnailUrl: listing.videoThumbnailUrl ?? listing.coverImageUrl ?? '',
            duration: listing.formattedVideoDuration ?? '0:00',
            isTabActive: isTabActive,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          listingDisplayTitle(listing),
          style: AppTextStyles.headline.copyWith(fontSize: 18),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              listing.formattedPrice,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (listing.isNegotiable) ...[
              const SizedBox(width: 8),
              Chip(
                label: const Text('قابل للتفاوض'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (listing.conditionLabelAr != null)
              _BadgeChip(
                label: listing.conditionLabelAr!,
                color: listing.condition == ListingCondition.newItem
                    ? Colors.green
                    : Colors.orange,
              ),
            if (listing.categoryBreadcrumb.isNotEmpty)
              _BadgeChip(label: listing.categoryBreadcrumb),
            if (listing.isPremiumListing)
              const PremiumListingChip(),
            if (listing.isProListing && !listing.isPremiumListing)
              const ProListingChip(),
          ],
        ),
        const SizedBox(height: 12),
        _ListingReferenceInfoSection(listing: listing),
        if (listing.isVehicleListing && listing.vehicleMetadata != null) ...[
          const SizedBox(height: 12),
          VehicleStatsRow(vehicle: listing.vehicleMetadata!),
        ],
        if (listing.hasStructuredMetadata && !metadataDisplay.isEmpty) ...[
          const SizedBox(height: 12),
          ListingMetadataDetailSection(
            rows: metadataDisplay.rows,
            chipGroups: metadataDisplay.chipGroups,
          ),
        ],
        if (listing.isVehicleListing && listing.vehicleMetadata != null) ...[
          const SizedBox(height: 16),
          Text('حالة الهيكل والطلاء', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          CarPaintSummaryWidget(
            panelConditions: listing.vehicleMetadata!.panelConditions,
            allOriginalLabelAr: 'جميع الأجزاء أصلية',
          ),
        ],
        if (listing.isVehicleListing || listing.isRealEstateListing) ...[
          const SizedBox(height: 16),
          PriceHistoryWidget(listingId: listing.id),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            _StatItem(
              icon: Icons.visibility_outlined,
              label: '${listing.viewsCount} مشاهدة',
            ),
            const SizedBox(width: 16),
            _StatItem(icon: Icons.schedule, label: listing.timeAgo),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18),
            const SizedBox(width: 4),
            Text(
              listing.locationAddress?.trim().isNotEmpty == true
                  ? listing.locationAddress!.trim()
                  : governorateNameAr(listing.governorate),
            ),
          ],
        ),
      ],
    );
  }
}

class _ListingReferenceInfoSection extends StatelessWidget {
  const _ListingReferenceInfoSection({required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ListingReferenceRow(
          label: 'رقم الإعلان',
          value: listing.referenceNo?.toString() ?? '—',
          valueStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const Divider(height: 1),
        _ListingReferenceRow(
          label: 'تاريخ الإعلان',
          value: formatListingPublicationDateAr(listing.createdAt),
        ),
      ],
    );
  }
}

class _ListingReferenceRow extends StatelessWidget {
  const _ListingReferenceRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingDescriptionTab extends StatelessWidget {
  const _ListingDescriptionTab({required this.listing});

  final ListingModel listing;

  @override
  Widget build(BuildContext context) {
    final description = listing.description.trim();

    if (description.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.notes_outlined, size: 52, color: Color(0xFFDDDDDD)),
            const SizedBox(height: 14),
            Text(
              'لم يضف صاحب الإعلان وصفاً',
              style: AppTextStyles.body.copyWith(color: const Color(0xFFAAAAAA)),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Text(
        description,
        style: AppTextStyles.body.copyWith(
          fontSize: 15,
          height: 1.85,
        ),
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
      ),
    );
  }
}

class _ListingLocationTab extends StatefulWidget {
  const _ListingLocationTab({required this.listing});

  final ListingModel listing;

  @override
  State<_ListingLocationTab> createState() => _ListingLocationTabState();
}

class _ListingLocationTabState extends State<_ListingLocationTab> {
  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;

    if (listing.latitude == null || listing.longitude == null) {
      return SizedBox(
        height: 220,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off_outlined, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 12),
              Text(
                'لم يتم تحديد الموقع',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    final position = LatLng(listing.latitude!, listing.longitude!);
    final address = listing.locationAddress?.trim();
    final governorateLabel = governorateNameAr(listing.governorate);

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: position,
                zoom: 15,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('listing_location'),
                  position: position,
                  infoWindow: InfoWindow(
                    title: listingDisplayTitle(listing),
                    snippet: address ?? '',
                  ),
                ),
              },
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
              mapToolbarEnabled: false,
              onMapCreated: (_) {},
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5EE),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          address?.isNotEmpty == true
                              ? address!
                              : 'الموقع المحدد',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (governorateLabel.isNotEmpty)
                          Text(
                            governorateLabel,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.right,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerCard extends StatelessWidget {
  const _SellerCard({
    required this.listing,
    required this.listingsCount,
  });

  final ListingModel listing;
  final int listingsCount;

  @override
  Widget build(BuildContext context) {
    final joinYear = listing.sellerCreatedAt != null
        ? DateFormat('yyyy', DisplayLocale.intlWesternArabic)
            .format(listing.sellerCreatedAt!)
        : null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                UserAvatar(
                  avatarSeed: listing.sellerAvatarSeed,
                  size: 56,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              listing.sellerName ?? 'بائع',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          if (listing.sellerIsVerified) ...[
                            const SizedBox(width: 4),
                            const VerifiedBadge(size: 18),
                          ],
                        ],
                      ),
                      if (listing.sellerRatingCount > 0) ...[
                        const SizedBox(height: 4),
                        starDisplay(
                          rating: listing.sellerAvgRating,
                          count: listing.sellerRatingCount,
                          starSize: 14,
                          onTap: () =>
                              context.push('/ratings/${listing.userId}'),
                        ),
                      ],
                      if (joinYear != null)
                        Text(
                          'عضو منذ $joinYear',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        '$listingsCount إعلان',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => context.push('/seller/${listing.userId}'),
              child: const Text('عرض جميع إعلاناته'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipsSection extends StatelessWidget {
  const _SafetyTipsSection();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text('نصائح الأمان'),
      children: const [
        ListTile(
          dense: true,
          leading: Icon(Icons.place_outlined),
          title: Text('قابل البائع في مكان عام'),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.payments_outlined),
          title: Text('لا تدفع مقدماً قبل معاينة المنتج'),
        ),
        ListTile(
          dense: true,
          leading: Icon(Icons.verified_user_outlined),
          title: Text('تحقّق من حالة المنتج قبل الشراء'),
        ),
      ],
    );
  }
}
