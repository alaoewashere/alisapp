import '../../../l10n/app_localizations.dart';
import '../../../widgets/user_avatar.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/constants/display_locale.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/listing_display_l10n.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
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
import '../../../shared/widgets/sello_app_bar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../favorites/providers/favorites_provider.dart';
import '../../home/widgets/listing_card.dart';
import '../providers/listing_detail_provider.dart';
import '../providers/listings_provider.dart';
import '../widgets/listing_analytics_panel.dart';
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
    final strings = ref.watch(appLocalizationsProvider);
    final listingAsync = referenceNo != null
        ? ref.watch(listingDetailByReferenceProvider(referenceNo!))
        : ref.watch(listingDetailProvider(listingId!));

    return listingAsync.when(
      loading: () => Scaffold(
        body: LoadingWidget(message: strings.loading),
      ),
      error: (e, _) => Scaffold(
        appBar: SelloAppBar(),
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
            appBar: SelloAppBar(),
            body: AppErrorWidget(
              message: strings.listingNotFound,
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

        final userId = ref.watch(currentUserIdProvider);
        final isOwner = userId != null && listing.userId == userId;

        return _ListingDetailLoadedView(
          listing: listing,
          isOwner: isOwner,
          listingId: listing.id,
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
      await ref.read(toggleFavoriteProvider.notifier).toggle(listing.id);
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
    required this.onToggleFavorite,
  });

  final ListingModel listing;
  final bool isOwner;
  final String listingId;
  final VoidCallback onToggleFavorite;

  @override
  ConsumerState<_ListingDetailLoadedView> createState() =>
      _ListingDetailLoadedViewState();
}

class _ListingDetailLoadedViewState
    extends ConsumerState<_ListingDetailLoadedView> {
  final GlobalKey _shareRepaintKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _shareImageReady = false;
  bool _sharing = false;
  bool _bottomBarVisible = true;
  double _lastScrollOffset = 0;

  static const _scrollHideThreshold = 48.0;
  static const _scrollDeltaThreshold = 6.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref
            .read(listingsRepositoryProvider)
            .incrementViews(widget.listingId);
      }
    });
    _precacheShareImage();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybePromptBuyerRating());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;

    bool? nextVisible;
    if (offset <= _scrollHideThreshold) {
      nextVisible = true;
    } else if (delta > _scrollDeltaThreshold) {
      nextVisible = false;
    } else if (delta < -_scrollDeltaThreshold) {
      nextVisible = true;
    }

    if (nextVisible != null && nextVisible != _bottomBarVisible) {
      setState(() => _bottomBarVisible = nextVisible!);
    }

    _lastScrollOffset = offset;
  }

  double get _scrollBottomInset => widget.isOwner ? 210 : 92;

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
      reviewedName: listing.sellerName ?? ref.read(appLocalizationsProvider).theSeller,
      reviewedAvatarSeed: listing.sellerAvatarSeed,
      subtitle: ref.read(appLocalizationsProvider).rateSeller,
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
        strings: ref.read(appLocalizationsProvider),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ref.read(appLocalizationsProvider).shareCardFailed),
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
          extendBody: true,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Consumer(
                    builder: (context, ref, _) {
                      final isFavorite = ref.watch(
                            toggleFavoriteProvider
                                .select((ids) => ids.contains(listing.id)),
                          ) ||
                          listing.isFavorite;
                      final favoriteLoading = ref.watch(
                        listingFavoriteLoadingProvider
                            .select((id) => id == listing.id),
                      );
                      return ListingDetailGallery(
                        listing: listing,
                        isFavorite: isFavorite,
                        favoriteLoading: favoriteLoading,
                        onBack: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.home),
                        onShare: () => shareListingUrl(
                          listing,
                          ref.read(appLocalizationsProvider),
                        ),
                        onFavorite: widget.onToggleFavorite,
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    _ListingDetailBody(
                      listing: listing,
                      isOwner: widget.isOwner,
                    ),
                    SizedBox(height: _scrollBottomInset),
                  ],
                ),
              ),
            ],
          ),
        ),
        AnimatedPositioned(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          left: 0,
          right: 0,
          bottom: _bottomBarVisible ? 0 : -320,
          child: ListingDetailBottomBar(
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
    final strings = ref.watch(appLocalizationsProvider);
    final theme = Theme.of(context);
    final listing = widget.listing;
    final isOwner = widget.isOwner;
    final sellerKey = (
      sellerId: listing.userId,
      excludeListingId: listing.id,
    );
    final otherListingsAsync = ref.watch(sellerOtherListingsProvider(sellerKey));
    final sellerCountAsync = ref.watch(sellerListingsCountProvider(listing.userId));
    final metadataDisplay = buildListingMetadataDisplay(listing, strings);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Persistent hero — price/title stay visible across all tabs.
          _ListingHero(listing: listing, strings: strings),
          const SizedBox(height: 18),
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: strings.tabListing),
              Tab(text: strings.tabDescription),
              Tab(text: strings.tabLocation),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              switch (_tabController.index) {
                case 1:
                  return _ListingDescriptionTab(
                    listing: listing,
                    strings: strings,
                  );
                case 2:
                  return _ListingLocationTab(
                    listing: listing,
                    strings: strings,
                  );
                case 0:
                default:
                  return _ListingInfoTab(
                    listing: listing,
                    metadataDisplay: metadataDisplay,
                    isTabActive: _tabController.index == 0,
                    strings: strings,
                    localeCode: ref.watch(categoryLocaleCodeProvider),
                  );
              }
            },
          ),
          const Divider(height: 32),
          _SellerCard(
            listing: listing,
            listingsCount: sellerCountAsync.value ?? 0,
            strings: strings,
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
                          strings.sellerOtherListings,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push(
                          '/seller/${listing.userId}',
                        ),
                        child: Text(strings.viewAll),
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
          _SafetyTipsSection(strings: strings),
          const SizedBox(height: 8),
          if (isOwner && listing.isPremiumListing) ...[
            ListingAnalyticsPanel(listingId: listing.id),
            const SizedBox(height: 16),
          ],
          if (!isOwner)
            TextButton(
              onPressed: () => showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                builder: (_) => ReportSheet(listingId: listing.id),
              ),
              child: Text(
                strings.reportThisListing,
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

/// Persistent hero header: title + hero volt price + key chips. Sits above the
/// tabs so price/title stay visible no matter which tab is open.
class _ListingHero extends StatelessWidget {
  const _ListingHero({required this.listing, required this.strings});

  final ListingModel listing;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    // Condition (used/new) already shows in the "إعلان" details tab below —
    // showing it again here was redundant. This badge instead says what the
    // listing itself is for (sale/rent), which isn't shown anywhere else and
    // matters most for categories like rental cars where it's easy to miss.
    final listingTypeLabel = listing.listingType.labelAr;
    // Skip on service-style categories (jobs, tutoring, home help) where
    // condition was never shown either and "for sale" reads oddly.
    final showListingTypeBadge = listing.condition != null ||
        listing.listingType == ListingType.rent;
    final breadcrumb = listing.categoryBreadcrumbFor(strings);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          listingDisplayTitle(listing),
          style: AppFonts.cairo(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.pureWhite,
            height: 1.3,
          ),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    listing.formattedPriceFor(strings),
                    style: AppFonts.cairo(
                      fontSize: 27,
                      fontWeight: FontWeight.w900,
                      color: AppColors.volt,
                      height: 1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (formatUsdApprox(listing.price).isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      formatUsdApprox(listing.price),
                      style: AppFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (listing.isNegotiable) ...[
              const SizedBox(width: 10),
              _NegotiablePill(label: strings.negotiable),
            ],
          ],
        ),
        if (showListingTypeBadge ||
            breadcrumb.isNotEmpty ||
            listing.isPremiumListing ||
            listing.isProListing) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (showListingTypeBadge)
                _BadgeChip(
                  label: listingTypeLabel,
                  color: listing.listingType == ListingType.rent
                      ? Colors.blue
                      : Colors.green,
                ),
              if (breadcrumb.isNotEmpty) _BadgeChip(label: breadcrumb),
              if (listing.isPremiumListing)
                const PremiumListingChip()
              else if (listing.isProListing)
                const ProListingChip(),
            ],
          ),
        ],
      ],
    );
  }
}

class _NegotiablePill extends StatelessWidget {
  const _NegotiablePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0x20FFFFFF)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.pureWhite,
        ),
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
    required this.strings,
    required this.localeCode,
    this.isTabActive = true,
  });

  final ListingModel listing;
  final ListingMetadataDisplay metadataDisplay;
  final AppLocalizations strings;
  final String localeCode;
  final bool isTabActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (listing.hasListingVideo) ...[
          Text(
            strings.videoTour,
            style: AppFonts.cairo(
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
        _ListingReferenceInfoSection(listing: listing, strings: strings),
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
          Text(strings.sectionBodyCondition, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          CarPaintSummaryWidget(
            panelConditions: listing.vehicleMetadata!.panelConditions,
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
              label: strings.viewsCount(listing.viewsCount.toString()),
            ),
            const SizedBox(width: 16),
            _StatItem(
              icon: Icons.schedule,
              label: listing.timeAgoFor(localeCode),
            ),
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

class _ListingReferenceInfoSection extends ConsumerWidget {
  const _ListingReferenceInfoSection({
    required this.listing,
    required this.strings,
  });

  final ListingModel listing;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final locale = ref.watch(localeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ListingReferenceRow(
          label: strings.listingNumber,
          value: listing.referenceNo?.toString() ?? '—',
          valueStyle: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        const Divider(height: 1),
        _ListingReferenceRow(
          label: strings.listedOn,
          value: formatListingPublicationDate(listing.createdAt, locale),
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
  const _ListingDescriptionTab({
    required this.listing,
    required this.strings,
  });

  final ListingModel listing;
  final AppLocalizations strings;

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
              strings.noDescriptionAdded,
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
  const _ListingLocationTab({
    required this.listing,
    required this.strings,
  });

  final ListingModel listing;
  final AppLocalizations strings;

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
                widget.strings.locationNotSet,
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
                color: const Color(0x40000000),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.location_on,
                      color: AppColors.volt,
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
                              : widget.strings.selectedLocation,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pureWhite,
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
                              color: AppColors.pureWhite.withValues(alpha: 0.85),
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
    required this.strings,
  });

  final ListingModel listing;
  final int listingsCount;
  final AppLocalizations strings;

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
                              listing.sellerName ?? strings.sellerLabel,
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
                          strings.memberSinceYear(joinYear),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      Text(
                        strings.listingsCountLabel(listingsCount.toString()),
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
              child: Text(strings.viewAllSellerListings),
            ),
          ],
        ),
      ),
    );
  }
}

class _SafetyTipsSection extends StatelessWidget {
  const _SafetyTipsSection({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(strings.safetyTipsTitle),
      children: [
        ListTile(
          dense: true,
          leading: const Icon(Icons.place_outlined),
          title: Text(strings.safetyTipPublicPlace),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.payments_outlined),
          title: Text(strings.safetyTipNoPrepay),
        ),
        ListTile(
          dense: true,
          leading: const Icon(Icons.verified_user_outlined),
          title: Text(strings.safetyTipInspect),
        ),
      ],
    );
  }
}
