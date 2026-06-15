import 'package:flutter/material.dart';

/// Panel condition values stored in `listings.metadata.panel_conditions`.
abstract final class CarPaintCondition {
  static const original = 'original';
  static const localPaint = 'local_paint';
  static const painted = 'painted';
  static const replaced = 'replaced';

  static const values = [original, localPaint, painted, replaced];
}

abstract final class CarPaintColors {
  static const defaultFill = Color(0xFFFFFFFF);
  static const original = Color(0xFFE0E0E0);
  static const localPaint = Color(0xFFFF9800);
  static const painted = Color(0xFF2196F3);
  static const replaced = Color(0xFFE53935);
  static const panelStroke = Color(0xFFD5D5D5);
  static const outline = panelStroke;
  static const wheelFill = Color(0xFFE8E8E8);
  static const addIcon = Color(0xFF1E88E5);
}

class CarPaintPanelDefinition {
  const CarPaintPanelDefinition({
    required this.key,
    required this.nameAr,
  });

  final String key;
  final String nameAr;
}

/// 13 tappable body panels (front at top).
const kCarPaintPanels = <CarPaintPanelDefinition>[
  CarPaintPanelDefinition(key: 'front_bumper', nameAr: 'الرقم الأمامي'),
  CarPaintPanelDefinition(key: 'hood', nameAr: 'الغطاء الأمامي'),
  CarPaintPanelDefinition(key: 'front_left_fender', nameAr: 'الجناح الأمامي أيسر'),
  CarPaintPanelDefinition(key: 'front_right_fender', nameAr: 'الجناح الأمامي أيمن'),
  CarPaintPanelDefinition(key: 'front_left_door', nameAr: 'الباب الأمامي أيسر'),
  CarPaintPanelDefinition(key: 'front_right_door', nameAr: 'الباب الأمامي أيمن'),
  CarPaintPanelDefinition(key: 'roof', nameAr: 'السقف'),
  CarPaintPanelDefinition(key: 'rear_left_door', nameAr: 'الباب الخلفي أيسر'),
  CarPaintPanelDefinition(key: 'rear_right_door', nameAr: 'الباب الخلفي أيمن'),
  CarPaintPanelDefinition(key: 'trunk', nameAr: 'غطاء الصندوق'),
  CarPaintPanelDefinition(key: 'rear_left_fender', nameAr: 'الجناح الخلفي أيسر'),
  CarPaintPanelDefinition(key: 'rear_right_fender', nameAr: 'الجناح الخلفي أيمن'),
  CarPaintPanelDefinition(key: 'rear_bumper', nameAr: 'الرقم الخلفي'),
];

const kCarPaintPanelCount = 13;

Color carPaintColorForCondition(String? condition) {
  return switch (condition) {
    CarPaintCondition.localPaint => CarPaintColors.localPaint,
    CarPaintCondition.painted => CarPaintColors.painted,
    CarPaintCondition.replaced => CarPaintColors.replaced,
    CarPaintCondition.original => CarPaintColors.defaultFill,
    _ => CarPaintColors.defaultFill,
  };
}

String carPaintConditionLabelAr(String condition) {
  return switch (condition) {
    CarPaintCondition.localPaint => 'صبغ محلي',
    CarPaintCondition.painted => 'مصبوغه',
    CarPaintCondition.replaced => 'مستبدلة',
    _ => 'أصلي',
  };
}

String? carPaintConditionForPanel(
  String panelKey,
  Map<String, String> panelConditions,
) {
  return panelConditions[panelKey];
}
