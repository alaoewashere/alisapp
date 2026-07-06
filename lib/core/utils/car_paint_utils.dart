import 'package:flutter/material.dart';

import '../constants/car_paint_panels.dart';

class CarPaintSummaryGroup {
  const CarPaintSummaryGroup({
    required this.condition,
    required this.color,
    required this.panelKeys,
  });

  final String condition;
  final Color color;
  final List<String> panelKeys;
}

List<CarPaintSummaryGroup> buildCarPaintSummaryGroups(
  Map<String, String> panelConditions,
) {
  final groups = <CarPaintSummaryGroup>[];

  for (final condition in [
    CarPaintCondition.localPaint,
    CarPaintCondition.painted,
    CarPaintCondition.replaced,
  ]) {
    final panelKeys = kCarPaintPanels
        .where((panel) => panelConditions[panel.key] == condition)
        .map((panel) => panel.key)
        .toList();
    if (panelKeys.isEmpty) continue;
    groups.add(
      CarPaintSummaryGroup(
        condition: condition,
        color: carPaintColorForCondition(condition),
        panelKeys: panelKeys,
      ),
    );
  }

  return groups;
}

bool carPaintAllOriginal(Map<String, String> panelConditions) {
  return panelConditions.isEmpty;
}

Map<String, String> carPaintConditionsForStorage(
  Map<String, String> panelConditions,
) {
  return Map<String, String>.from(panelConditions)
    ..removeWhere((_, value) => value == CarPaintCondition.original);
}
