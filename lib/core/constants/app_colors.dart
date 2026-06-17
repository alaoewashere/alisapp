import 'package:flutter/material.dart';

/// Sello dark "fintech" design tokens.
///
/// Member names are preserved from the previous light theme so every existing
/// consumer restyles automatically — only the values changed.
abstract final class AppColors {
  // --- New base palette -----------------------------------------------------
  /// Deep Canvas — scaffold / page background.
  static const canvas = Color(0xFF131315);

  /// Field Carbon — cards, inputs, sheets, secondary surfaces.
  static const fieldCarbon = Color(0xFF18181A);

  /// Volt Green — primary accent (buttons, active nav, focus, links).
  static const volt = Color(0xFFD4FF3A);

  /// Pure White — primary text/icons on dark surfaces.
  static const pureWhite = Color(0xFFFFFFFF);

  // --- Mapped roles (names kept for back-compat) ----------------------------
  static const primary = volt;
  static const accent = volt;
  static const background = canvas;
  static const backgroundGradientStart = Color(0xFF161618);

  /// Legacy alias.
  static const secondary = accent;

  static const cardBg = fieldCarbon;
  static const textDark = pureWhite;
  static const textMuted = Color(0x99FFFFFF); // ~60% white
  static const borderLight = Color(0x14FFFFFF); // ~8% white

  /// Sello chat bubble palette (dark fintech).
  static const chatBackground = canvas;
  static const surface = fieldCarbon;
  static const chatSent = volt; // sent bubble = volt, dark text via [surface]
  static const chatTextDark = pureWhite; // received bubble text
  static const chatBorder = Color(0x1FFFFFFF); // ~12% white
  static const chatReadReceipt = Color(0xFF1B6B3A); // dark tick on volt
  static const textLight = Color(0x73FFFFFF); // ~45% white

  static const surfaceMuted = Color(0xFF202023);
  static const pending = Color(0xFFFF9800);
  static const approved = Color(0xFF4CAF50);
  static const rejected = Color(0xFFF44336);
  static const heartAccent = Color(0xFFE63946);

  static const badgeBg = Color(0xCC18181A);
  static const badgeText = volt;

  // Surfaces / soft separation on Field Carbon.
  static const glassBorder = Color(0x1AFFFFFF); // ~10% white
  static const glassFill = fieldCarbon;
  static const navFill = Color(0xE618181A); // carbon @ ~90% for blur
  static const microShadow = Color(0x59000000); // soft dark elevation

  /// Volt gradient for primary CTAs / floating add button.
  static const premiumGradient = LinearGradient(
    colors: [volt, Color(0xFFB6E62E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient for premium (مميز) listing badges — kept as a gold accent.
  static const premiumGold = Color(0xFFF5A623);
  static const premiumGoldDark = Color(0xFFE8940A);

  /// Alias for premium gold accent.
  static const gold = premiumGold;

  static const listingPremiumGoldGradient = LinearGradient(
    colors: [premiumGold, premiumGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // --- Listing package tier badge gradients (~135° metallic sheen) ------------
  static const packageFreeGradient = LinearGradient(
    colors: [Color(0xFF9A9A9E), Color(0xFF4A4A4E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Green Smoke (#999F54) → Verdun Green (#48521C).
  static const packageProGradient = LinearGradient(
    colors: [Color(0xFFB5BA82), Color(0xFF999F54), Color(0xFF48521C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.45, 1.0],
  );

  static const packagePremiumGradient = LinearGradient(
    colors: [Color(0xFFF5D77A), Color(0xFFC9921E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [backgroundGradientStart, background],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
