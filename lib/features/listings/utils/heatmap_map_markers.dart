import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/utils/listing_heatmap_utils.dart';
import '../widgets/heatmap_density_badge.dart';

/// Stable marker key → neighborhood density payload for tap handling.
Map<String, HeatmapAreaMarkerData> heatmapMarkerLookup(
  List<HeatmapAreaMarkerData> markers,
) {
  return {
    for (final marker in markers) marker.neighborhood.slug: marker,
  };
}

String? heatmapMarkerSlug(Marker marker) {
  final key = marker.key;
  if (key is ValueKey<String>) return key.value;
  return null;
}

HeatmapAreaMarkerData? heatmapMarkerData(
  Marker marker,
  Map<String, HeatmapAreaMarkerData> lookup,
) {
  final slug = heatmapMarkerSlug(marker);
  if (slug == null) return null;
  return lookup[slug];
}

int heatmapClusterListingCount(
  List<Marker> markers,
  Map<String, HeatmapAreaMarkerData> lookup,
) {
  var total = 0;
  for (final marker in markers) {
    total += heatmapMarkerData(marker, lookup)?.listingCount ?? 0;
  }
  return total;
}

List<HeatmapAreaMarkerData> heatmapClusterAreas(
  List<Marker> markers,
  Map<String, HeatmapAreaMarkerData> lookup,
) {
  final areas = <HeatmapAreaMarkerData>[];
  for (final marker in markers) {
    final data = heatmapMarkerData(marker, lookup);
    if (data != null) areas.add(data);
  }
  areas.sort(
    (a, b) => b.listingCount.compareTo(a.listingCount),
  );
  return areas;
}

List<Marker> buildHeatmapMapMarkers({
  required List<HeatmapAreaMarkerData> markers,
}) {
  return markers
      .map(
        (data) => Marker(
          key: ValueKey<String>(data.neighborhood.slug),
          point: LatLng(
            data.neighborhood.latitude,
            data.neighborhood.longitude,
          ),
          width: HeatmapDensityBadge.badgeSize,
          height: HeatmapDensityBadge.badgeSize,
          alignment: Alignment.center,
          child: HeatmapDensityBadge(count: data.listingCount),
        ),
      )
      .toList();
}

/// Pinch/pan-friendly map interaction flags (rotation disabled).
const heatmapMapInteractionFlags =
    InteractiveFlag.drag |
    InteractiveFlag.flingAnimation |
    InteractiveFlag.pinchMove |
    InteractiveFlag.pinchZoom |
    InteractiveFlag.doubleTapZoom |
    InteractiveFlag.doubleTapDragZoom;
