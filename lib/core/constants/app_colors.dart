import 'package:flutter/material.dart';

/// Cupertino Glass palette — sourced from souqly-redesign-studio (الزجاجي الكوبرتيني).
abstract final class AppColors {
  static const primary = Color(0xFF005F54);
  static const accent = Color(0xFF00897B);
  static const background = Color(0xFFF0F2F5);
  static const backgroundGradientStart = Color(0xFFE4E6EB);

  /// Legacy alias.
  static const secondary = accent;

  static const cardBg = Color(0xB3FFFFFF);
  static const textDark = Color(0xFF1D1D1F);
  static const textMuted = Color(0xFF86868B);
  static const borderLight = Color(0xFFE5E5EA);

  /// Sello chat bubble palette (iMessage-style).
  static const chatBackground = Color(0xFFF0EFE0);
  static const surface = Color(0xFFFCFFF5);
  static const chatSent = Color(0xFF48521C);
  static const chatTextDark = Color(0xFF3C3C3C);
  static const chatBorder = Color(0xFFDBDAAF);
  static const chatReadReceipt = Color(0xFF8FD9B0);
  static const textLight = Color(0xFF8A8A8A);

  static const surfaceMuted = Color(0xFFE0E0E0);
  static const pending = Color(0xFFFF9800);
  static const approved = Color(0xFF4CAF50);
  static const rejected = Color(0xFFF44336);
  static const heartAccent = Color(0xFFE63946);

  static const badgeBg = Color(0xCCFFFFFF);
  static const badgeText = Color(0xFF005F54);

  // Glass surfaces
  static const glassBorder = Color(0x66FFFFFF);
  static const glassFill = Color(0xB3FFFFFF);
  static const navFill = Color(0x99FFFFFF);
  static const microShadow = Color(0x08000000);

  static const premiumGradient = LinearGradient(
    colors: [Color(0xFF005F54), Color(0xFF00897B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gold gradient for premium (مميز) listing badges.
  static const premiumGold = Color(0xFFF5A623);
  static const premiumGoldDark = Color(0xFFE8940A);

  /// Alias for premium gold accent.
  static const gold = premiumGold;

  static const listingPremiumGoldGradient = LinearGradient(
    colors: [premiumGold, premiumGoldDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const backgroundGradient = LinearGradient(
    colors: [backgroundGradientStart, background],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
