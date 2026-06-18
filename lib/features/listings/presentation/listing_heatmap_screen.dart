import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/iraq_neighborhoods.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../core/utils/listing_heatmap_utils.dart';
import '../../../features/auth/widgets/auth_form_styles.dart';
import '../utils/heatmap_map_markers.dart';
import '../widgets/heatmap_density_badge.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/filter_model.dart';
import '../../../shared/widgets/sello_app_bar.dart';
import '../models/listing_density.dart';
import '../providers/listing_heatmap_provider.dart';
import '../providers/post_listing_provider.dart';
import '../providers/search_provider.dart';

class ListingHeatmapScreen extends ConsumerWidget {
  const ListingHeatmapScreen({super.key});

  static const _tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedSlug = ref.watch(heatmapCategorySlugProvider);
    final densityAsync = ref.watch(listingDensityProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: SelloAppBar(
        backgroundColor: AppColors.canvas,
        title: Text(
          'خريطة الإعلانات',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            _CategoryFilterRow(selectedSlug: selectedSlug),
            const SizedBox(height: 8),
            Expanded(
              child: densityAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.volt),
                ),
                error: (_, _) => Center(
                  child: Text(
                    'تعذّر تحميل بيانات الكثافة',
                    style: AppFonts.cairo(color: AppColors.textMuted),
                  ),
                ),
                data: (densities) => _HeatmapView(
                  densities: densities,
                  categorySlug: selectedSlug,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryFilterRow extends ConsumerWidget {
  const _CategoryFilterRow({required this.selectedSlug});

  final String? selectedSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: heatmapCategoryFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = heatmapCategoryFilters[index];
          final selected = selectedSlug == filter.slug ||
              (selectedSlug == null && filter.slug == null);

          return FilterChip(
            label: Text(
              filter.labelAr,
              style: AppFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.canvas : AppColors.pureWhite,
              ),
            ),
            selected: selected,
            showCheckmark: false,
            backgroundColor: AppColors.fieldCarbon,
            selectedColor: AppColors.volt,
            side: BorderSide(
              color: selected ? AppColors.volt : const Color(0x15FFFFFF),
            ),
            onSelected: (_) {
              ref.read(heatmapCategorySlugProvider.notifier).select(filter.slug);
            },
          );
        },
      ),
    );
  }
}

class _HeatmapView extends ConsumerStatefulWidget {
  const _HeatmapView({
    required this.densities,
    required this.categorySlug,
  });

  final List<ListingDensity> densities;
  final String? categorySlug;

  @override
  ConsumerState<_HeatmapView> createState() => _HeatmapViewState();
}

class _HeatmapViewState extends ConsumerState<_HeatmapView> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final areaMarkers = buildHeatmapMarkers(
      areaCounts: {
        for (final row in widget.densities) row.areaName: row.listingCount,
      },
    );
    final lookup = heatmapMarkerLookup(areaMarkers);
    final mapMarkers = buildHeatmapMapMarkers(markers: areaMarkers);

    if (areaMarkers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'لا توجد إعلانات نشطة في المناطق المعروضة حالياً',
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: const LatLng(baghdadMapCenterLat, baghdadMapCenterLng),
        initialZoom: 11,
        minZoom: 5,
        maxZoom: 16,
        interactionOptions: const InteractionOptions(
          flags: heatmapMapInteractionFlags,
          enableMultiFingerGestureRace: true,
          pinchZoomThreshold: 0.25,
          pinchMoveThreshold: 32,
        ),
      ),
      children: [
        TileLayer(
          urlTemplate: ListingHeatmapScreen._tileUrlTemplate,
          subdomains: const ['a', 'b', 'c', 'd'],
          retinaMode: RetinaMode.isHighDensity(context),
        ),
        MarkerClusterLayerWidget(
          options: MarkerClusterLayerOptions(
            markers: mapMarkers,
            maxZoom: 16,
            maxClusterRadius: 55,
            disableClusteringAtZoom: 14,
            size: const Size(
              HeatmapDensityBadge.badgeSize,
              HeatmapDensityBadge.badgeSize,
            ),
            alignment: Alignment.center,
            zoomToBoundsOnClick: false,
            centerMarkerOnClick: false,
            spiderfyCluster: false,
            showPolygon: false,
            onMarkerTap: (marker) {
              final data = heatmapMarkerData(marker, lookup);
              if (data == null) return;
              _showAreaSheet(
                context: context,
                marker: data,
                categorySlug: widget.categorySlug,
              );
            },
            onClusterTap: (cluster) {
              final areas = heatmapClusterAreas(cluster.mapMarkers, lookup);
              if (areas.isEmpty) return;
              if (areas.length == 1) {
                _showAreaSheet(
                  context: context,
                  marker: areas.single,
                  categorySlug: widget.categorySlug,
                );
                return;
              }
              _showClusterSheet(
                context: context,
                areas: areas,
                categorySlug: widget.categorySlug,
              );
            },
            builder: (context, clusteredMarkers) {
              final count = heatmapClusterListingCount(clusteredMarkers, lookup);
              return HeatmapDensityBadge(
                count: count,
                compact: clusteredMarkers.length > 1,
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _showClusterSheet({
    required BuildContext context,
    required List<HeatmapAreaMarkerData> areas,
    required String? categorySlug,
  }) {
    final total = areas.fold<int>(0, (sum, area) => sum + area.listingCount);

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Color(0x10FFFFFF))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${arabicNumber(areas.length)} مناطق · ${arabicNumber(total)} إعلان',
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'اختر منطقة لعرض الإعلانات',
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.4,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: areas.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final area = areas[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            area.neighborhood.nameAr,
                            style: AppFonts.cairo(
                              fontWeight: FontWeight.w600,
                              color: AppColors.pureWhite,
                            ),
                          ),
                          subtitle: Text(
                            heatmapDensitySubtitle(
                              areaName: area.neighborhood.nameAr,
                              listingCount: area.listingCount,
                              categorySlug: categorySlug,
                            ),
                            style: AppFonts.cairo(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.chevron_left_rounded,
                            color: AppColors.textMuted,
                          ),
                          onTap: () {
                            Navigator.pop(sheetContext);
                            _showAreaSheet(
                              context: context,
                              marker: area,
                              categorySlug: categorySlug,
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAreaSheet({
    required BuildContext context,
    required HeatmapAreaMarkerData marker,
    required String? categorySlug,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.canvas,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(top: BorderSide(color: Color(0x10FFFFFF))),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    heatmapSheetTitle(marker.neighborhood.nameAr),
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    heatmapDensitySubtitle(
                      areaName: marker.neighborhood.nameAr,
                      listingCount: marker.listingCount,
                      categorySlug: categorySlug,
                    ),
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 20),
                  AuthPrimaryButton(
                    label: 'عرض الإعلانات',
                    loginStyle: true,
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await _openFilteredListings(
                        context: context,
                        areaName: marker.neighborhood.nameAr,
                        categorySlug: categorySlug,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openFilteredListings({
    required BuildContext context,
    required String areaName,
    required String? categorySlug,
  }) async {
    int? categoryId;
    if (categorySlug != null) {
      final categories = await ref.read(allCategoriesProvider.future);
      categoryId = _rootCategoryIdForSlug(categories, categorySlug);
    }

    final filter = FilterModel(
      areaName: areaName,
      categoryId: categoryId,
    );

    ref.read(filterProvider.notifier).setFilter(filter);
    await ref.read(searchResultsProvider.notifier).search(filter);
    if (context.mounted) {
      context.go(AppRoutes.searchResults);
    }
  }

  int? _rootCategoryIdForSlug(List<CategoryModel> categories, String slug) {
    for (final category in categories) {
      if (category.slug == slug && category.parentId == null) {
        return category.id;
      }
    }
    return null;
  }
}
