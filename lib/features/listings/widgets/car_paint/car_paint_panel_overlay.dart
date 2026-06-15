import 'package:flutter/material.dart';

import '../../../../core/constants/car_paint_panels.dart';
import 'car_paint_panel_layout.dart';

/// Alpha mask PNG (316×402) — one opaque pixel per grey panel pixel in the diagram.
String carPaintPanelMaskAsset(String panelId) =>
    'assets/images/car_paint_masks/$panelId.png';

/// Paints a condition color only inside the exact grey panel silhouette.
class CarPaintPanelOverlay extends StatelessWidget {
  const CarPaintPanelOverlay({
    super.key,
    required this.panelId,
    required this.condition,
    required this.width,
    required this.height,
    this.opacity = 0.65,
  });

  final String panelId;
  final String condition;
  final double width;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final tint = carPaintOverlayColor(condition).withValues(alpha: opacity);

    return Positioned(
      left: 0,
      top: 0,
      width: width,
      height: height,
      child: IgnorePointer(
        child: Image.asset(
          carPaintPanelMaskAsset(panelId),
          width: width,
          height: height,
          fit: BoxFit.fill,
          color: tint,
          colorBlendMode: BlendMode.srcIn,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
          isAntiAlias: true,
        ),
      ),
    );
  }
}

/// One overlay per non-original panel, clipped to PNG-derived mask shape.
List<Widget> buildCarPaintPanelOverlays({
  required Map<String, String> panelConditions,
  required double width,
  required double height,
  double opacity = 0.65,
}) {
  return kCarPaintPanelLayouts
      .where((panel) {
        final condition = panelConditions[panel.id];
        return condition != null && condition != CarPaintCondition.original;
      })
      .map(
        (panel) => CarPaintPanelOverlay(
          panelId: panel.id,
          condition: panelConditions[panel.id]!,
          width: width,
          height: height,
          opacity: opacity,
        ),
      )
      .toList();
}
