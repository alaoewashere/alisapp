import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shared radii, shadows, and decorations from souqly-redesign-studio.
abstract final class AppDecorations {
  static const double cardRadius = 18;
  static const double navRadius = 30;
  static const double chipRadius = 16;

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 28,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get navShadow => const [
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10)),
  ];

  static BoxDecoration glassCard({double radius = cardRadius}) => BoxDecoration(
    color: AppColors.glassFill,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.glassBorder, width: 1),
    boxShadow: cardShadow,
  );
}
