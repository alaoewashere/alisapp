import 'package:flutter/material.dart';

import '../../../../core/constants/car_paint_panels.dart';

/// Percentage-positioned panel on `car_diagram.png` (316×402).
class CarPaintPanelLayout {
  const CarPaintPanelLayout({
    required this.id,
    required this.nameAr,
    required this.leftPct,
    required this.topPct,
    required this.widthPct,
    required this.heightPct,
  });

  final String id;
  final String nameAr;
  final double leftPct;
  final double topPct;
  final double widthPct;
  final double heightPct;

  Offset centerForSize(double width, double height) {
    return rectForSize(width, height).center;
  }

  Rect rectForSize(double width, double height) {
    return Rect.fromLTWH(
      leftPct * width,
      topPct * height,
      widthPct * width,
      heightPct * height,
    );
  }
}

/// Pixel-measured from `car_diagram.png` (316×402). Do not guess — re-measure via calibrator if needed.
const kCarPaintPanelLayouts = <CarPaintPanelLayout>[
  CarPaintPanelLayout(
    id: 'front_bumper',
    nameAr: 'الرقم الأمامي',
    leftPct: 0.278,
    topPct: 0.005,
    widthPct: 0.443,
    heightPct: 0.095,
  ),
  CarPaintPanelLayout(
    id: 'hood',
    nameAr: 'الغطاء الأمامي',
    leftPct: 0.278,
    topPct: 0.117,
    widthPct: 0.443,
    heightPct: 0.199,
  ),
  CarPaintPanelLayout(
    id: 'front_left_fender',
    nameAr: 'الجناح الأمامي الأيسر',
    leftPct: 0.000,
    topPct: 0.117,
    widthPct: 0.259,
    heightPct: 0.219,
  ),
  CarPaintPanelLayout(
    id: 'front_right_fender',
    nameAr: 'الجناح الأمامي الأيمن',
    leftPct: 0.741,
    topPct: 0.117,
    widthPct: 0.259,
    heightPct: 0.219,
  ),
  CarPaintPanelLayout(
    id: 'front_left_door',
    nameAr: 'الباب الأمامي الأيسر',
    leftPct: 0.000,
    topPct: 0.336,
    widthPct: 0.259,
    heightPct: 0.174,
  ),
  CarPaintPanelLayout(
    id: 'front_right_door',
    nameAr: 'الباب الأمامي الأيمن',
    leftPct: 0.741,
    topPct: 0.336,
    widthPct: 0.259,
    heightPct: 0.174,
  ),
  CarPaintPanelLayout(
    id: 'roof',
    nameAr: 'السقف',
    leftPct: 0.307,
    topPct: 0.510,
    widthPct: 0.373,
    heightPct: 0.149,
  ),
  CarPaintPanelLayout(
    id: 'rear_left_door',
    nameAr: 'الباب الخلفي الأيسر',
    leftPct: 0.000,
    topPct: 0.510,
    widthPct: 0.259,
    heightPct: 0.162,
  ),
  CarPaintPanelLayout(
    id: 'rear_right_door',
    nameAr: 'الباب الخلفي الأيمن',
    leftPct: 0.741,
    topPct: 0.510,
    widthPct: 0.259,
    heightPct: 0.162,
  ),
  CarPaintPanelLayout(
    id: 'rear_left_fender',
    nameAr: 'الجناح الخلفي الأيسر',
    leftPct: 0.000,
    topPct: 0.672,
    widthPct: 0.259,
    heightPct: 0.211,
  ),
  CarPaintPanelLayout(
    id: 'rear_right_fender',
    nameAr: 'الجناح الخلفي الأيمن',
    leftPct: 0.741,
    topPct: 0.672,
    widthPct: 0.259,
    heightPct: 0.211,
  ),
  CarPaintPanelLayout(
    id: 'trunk',
    nameAr: 'غطاء الصندوق',
    leftPct: 0.278,
    topPct: 0.659,
    widthPct: 0.443,
    heightPct: 0.224,
  ),
  CarPaintPanelLayout(
    id: 'rear_bumper',
    nameAr: 'الرقم الخلفي',
    leftPct: 0.278,
    topPct: 0.896,
    widthPct: 0.443,
    heightPct: 0.104,
  ),
];

CarPaintPanelLayout? carPaintPanelLayoutById(String id) {
  for (final panel in kCarPaintPanelLayouts) {
    if (panel.id == id) return panel;
  }
  return null;
}

/// Natural image size 316×402 (from PNG file).
const kCarPaintImageWidth = 316.0;
const kCarPaintImageHeight = 402.0;
const kCarPaintImageAspectRatio = kCarPaintImageHeight / kCarPaintImageWidth;

const kCarPaintBaseImageAsset = 'assets/images/car_diagram.png';

Color carPaintOverlayColor(String condition) {
  return carPaintColorForCondition(condition);
}
