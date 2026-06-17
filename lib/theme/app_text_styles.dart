import 'package:flutter/material.dart';

import '../core/theme/app_fonts.dart';
import '../core/constants/app_colors.dart';

/// Semantic Arabic typography for Sello (Thmanyah Sans / Serif Text / Serif Display).
abstract final class AppTextStyles {
  /// Screen titles, section headers.
  static TextStyle get headline => AppFonts.sans(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
        height: 1.4,
      );

  /// Card titles, field labels above inputs.
  static TextStyle get subheading => AppFonts.sans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
      );

  /// Descriptions, listing details, general content.
  static TextStyle get body => AppFonts.serifText(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xE6FFFFFF), // ~90% white
        height: 1.75,
      );

  /// Placeholder-adjacent helper text, section captions.
  static TextStyle get caption => AppFonts.serifText(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
      );

  /// Primary action buttons (dark text on Volt Green).
  static TextStyle get button => AppFonts.sans(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.canvas,
        letterSpacing: 0.3,
      );

  /// Text the user types in form fields.
  static TextStyle get input => AppFonts.serifText(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.pureWhite,
      );

  /// Prices and numeric emphasis — large balance-style figures.
  static TextStyle get price => AppFonts.sans(
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColors.pureWhite,
      );

  /// Input hint / placeholder.
  static TextStyle get hint => AppFonts.serifText(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0x66FFFFFF), // ~40% white
      );

  /// Character counters.
  static TextStyle get counter => AppFonts.serifDisplay(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: const Color(0x59FFFFFF), // ~35% white
      );

  /// Builds Material [TextTheme] aligned with this system.
  static TextTheme textTheme(ColorScheme scheme) {
    return TextTheme(
      displayLarge: headline.copyWith(fontSize: 32),
      displayMedium: headline.copyWith(fontSize: 28),
      displaySmall: headline.copyWith(fontSize: 24),
      headlineLarge: headline,
      headlineMedium: headline.copyWith(fontSize: 20),
      headlineSmall: subheading.copyWith(fontSize: 17),
      titleLarge: subheading.copyWith(fontSize: 16),
      titleMedium: subheading,
      titleSmall: subheading.copyWith(fontSize: 14),
      bodyLarge: body.copyWith(fontSize: 15),
      bodyMedium: body,
      bodySmall: caption,
      labelLarge: button.copyWith(color: scheme.onPrimary),
      labelMedium: caption.copyWith(fontWeight: FontWeight.w600),
      labelSmall: counter,
    );
  }

  static TextStyle priceColored(BuildContext context) {
    return price.copyWith(color: AppColors.primary);
  }
}
