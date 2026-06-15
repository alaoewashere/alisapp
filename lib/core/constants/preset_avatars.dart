import 'package:flutter/material.dart';

/// Eight preset profile avatars (colored circles + person icon).
abstract final class PresetAvatars {
  static const selectedBorder = Color(0xFF1EC878);
  static const unselectedBorder = Color(0xFFE0E0E0);

  static const colors = <Color>[
    Color(0xFF1EC878),
    Color(0xFF4A90D9),
    Color(0xFFE67E22),
    Color(0xFF9B59B6),
    Color(0xFFE74C3C),
    Color(0xFF1ABC9C),
    Color(0xFFF39C12),
    Color(0xFF2ECC71),
  ];

  static int clampIndex(int index) {
    if (index < 0) return 0;
    if (index >= colors.length) return colors.length - 1;
    return index;
  }

  static Color colorAt(int index) => colors[clampIndex(index)];
}
