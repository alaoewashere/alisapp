import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Shared radii, shadows, and decorations from souqly-redesign-studio.
abstract final class AppDecorations {
  static const double cardRadius = 20;
  static const double navRadius = 30;
  static const double chipRadius = 16;

  static List<BoxShadow> get cardShadow => const [
    BoxShadow(
      color: AppColors.microShadow,
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  static List<BoxShadow> get navShadow => const [
    BoxShadow(color: Color(0x0F000000), blurRadius: 16, offset: Offset(0, 8)),
  ];

  static BoxDecoration glassCard({double radius = cardRadius}) => BoxDecoration(
    color: AppColors.glassFill,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: AppColors.glassBorder, width: 0.5),
    boxShadow: cardShadow,
  );
}
