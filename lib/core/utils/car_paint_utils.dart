import 'package:flutter/material.dart';

import '../constants/car_paint_panels.dart';

class CarPaintSummaryGroup {
  const CarPaintSummaryGroup({
    required this.condition,
    required this.labelAr,
    required this.color,
    required this.panelNamesAr,
  });

  final String condition;
  final String labelAr;
  final Color color;
  final List<String> panelNamesAr;
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
    final names = kCarPaintPanels
        .where((panel) => panelConditions[panel.key] == condition)
        .map((panel) => panel.nameAr)
        .toList();
    if (names.isEmpty) continue;
    groups.add(
      CarPaintSummaryGroup(
        condition: condition,
        labelAr: carPaintConditionLabelAr(condition),
        color: carPaintColorForCondition(condition),
        panelNamesAr: names,
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
