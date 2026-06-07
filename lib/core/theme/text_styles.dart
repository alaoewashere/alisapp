import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

abstract final class AppTextStyles {
  static TextTheme textTheme(ColorScheme scheme) {
    return TextTheme(
      headlineMedium: TextStyle(
        fontWeight: FontWeight.bold,
        color: scheme.onSurface,
      ),
      titleLarge: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleMedium: TextStyle(
        fontWeight: FontWeight.w600,
        color: scheme.onSurface,
      ),
      titleSmall: TextStyle(
        fontWeight: FontWeight.w500,
        color: scheme.onSurface,
      ),
      bodyLarge: TextStyle(color: scheme.onSurface),
      bodyMedium: TextStyle(color: scheme.onSurfaceVariant),
      bodySmall: TextStyle(color: scheme.outline),
      labelSmall: TextStyle(color: scheme.outline, fontSize: 11),
    );
  }

  static TextStyle price(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
        );
  }
}
