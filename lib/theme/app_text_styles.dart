import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/app_colors.dart';

/// Semantic Arabic typography for Sello (Cairo + Tajawal + Inter).
abstract final class AppTextStyles {
  /// Screen titles, section headers.
  static TextStyle get headline => GoogleFonts.cairo(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111111),
        height: 1.4,
      );

  /// Card titles, field labels above inputs.
  static TextStyle get subheading => GoogleFonts.cairo(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF222222),
      );

  /// Descriptions, listing details, general content.
  static TextStyle get body => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF333333),
        height: 1.75,
      );

  /// Placeholder-adjacent helper text, section captions.
  static TextStyle get caption => GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFAAAAAA),
      );

  /// Primary action buttons.
  static TextStyle get button => GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        letterSpacing: 0.3,
      );

  /// Text the user types in form fields.
  static TextStyle get input => GoogleFonts.tajawal(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF1A1A1A),
      );

  /// Prices and numeric emphasis (Latin numerals).
  static TextStyle get price => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF111111),
      );

  /// Input hint / placeholder.
  static TextStyle get hint => GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFBBBBBB),
      );

  /// Character counters (Inter numerals).
  static TextStyle get counter => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: const Color(0xFFCCCCCC),
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
