import 'package:flutter/material.dart';

// ============================================================
//  SELLO BRAND KIT — Flutter Theme
//  A modern Iraqi classifieds marketplace app
//  Generated from brand kit design system
// ============================================================

// ------------------------------------------------------------
//  1. COLOR PALETTE
// ------------------------------------------------------------
class SouqlyColors {
  SouqlyColors._();

  /// Primary — main brand color (black)
  static const Color primary = Color(0xFF000000);

  /// Secondary — white, used for backgrounds and contrast
  static const Color secondary = Color(0xFFFFFFFF);

  /// Text — dark gray for body copy
  static const Color text = Color(0xFF333333);

  /// Borders — medium gray for dividers and outlines
  static const Color border = Color(0xFF888888);

  /// Backgrounds — light gray for surface backgrounds
  static const Color background = Color(0xFFCCCCCC);

  // Semantic / utility
  static const Color error = Color(0xFFD32F2F);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF000000);
  static const Color onBackground = Color(0xFF333333);
  static const Color onSurface = Color(0xFF333333);
  static const Color onError = Color(0xFFFFFFFF);

  // Ghost / outline button
  static const Color ghostBorder = Color(0xFF000000);
  static const Color ghostText = Color(0xFF000000);

  // Hover state (slightly lighter primary)
  static const Color hover = Color(0xFF333333);

  // Active state (same as secondary/dark gray)
  static const Color active = Color(0xFF444444);

  // Input states
  static const Color inputEmpty = Color(0xFFCCCCCC);
  static const Color inputTyped = Color(0xFF888888);
  static const Color inputFocus = Color(0xFF000000);
  static const Color inputError = Color(0xFFD32F2F);
}

// ------------------------------------------------------------
//  2. TYPOGRAPHY — Thmanyah Sans (bundled under assets/fonts/)
// ------------------------------------------------------------
class SouqlyTypography {
  SouqlyTypography._();

  // Cairo Semibold — 24pt (large headings, Arabic welcome)
  static const TextStyle displayLarge = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w600,
    fontSize: 24,
    color: SouqlyColors.text,
    letterSpacing: -0.3,
  );

  // Cairo Semibold — 18pt (section headings)
  static const TextStyle headlineMedium = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: SouqlyColors.text,
    letterSpacing: -0.2,
  );

  // Cairo Regular — 16pt (body, primary content)
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w400,
    fontSize: 16,
    color: SouqlyColors.text,
    height: 1.5,
  );

  // Cairo Regular — 14pt (secondary body, labels)
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w400,
    fontSize: 14,
    color: SouqlyColors.text,
    height: 1.5,
  );

  // Cairo Regular — 12pt (captions, metadata)
  static const TextStyle bodySmall = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w400,
    fontSize: 12,
    color: SouqlyColors.border,
    height: 1.4,
  );

  // Convenience: Arabic text style (RTL-aware)
  static const TextStyle arabic = TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w600,
    fontSize: 20,
    color: SouqlyColors.text,
    height: 1.6,
  );
}

// ------------------------------------------------------------
//  3. TEXT THEME
// ------------------------------------------------------------
const TextTheme souqlyTextTheme = TextTheme(
  displayLarge: SouqlyTypography.displayLarge,
  headlineMedium: SouqlyTypography.headlineMedium,
  bodyLarge: SouqlyTypography.bodyLarge,
  bodyMedium: SouqlyTypography.bodyMedium,
  bodySmall: SouqlyTypography.bodySmall,
);

// ------------------------------------------------------------
//  4. BUTTON THEMES
// ------------------------------------------------------------

// Primary Button — black fill, white text
final ElevatedButtonThemeData
souqlyElevatedButtonTheme = ElevatedButtonThemeData(
  style:
      ElevatedButton.styleFrom(
        backgroundColor: SouqlyColors.primary,
        foregroundColor: SouqlyColors.onPrimary,
        textStyle: const TextStyle(
          fontFamily: 'ThmanyahSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
      ).copyWith(
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) return SouqlyColors.hover;
          if (states.contains(WidgetState.pressed)) return SouqlyColors.active;
          return null;
        }),
      ),
);

// Secondary Button — gray fill, white text
final ElevatedButtonThemeData souqlySecondaryButtonTheme =
    ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SouqlyColors.border,
        foregroundColor: SouqlyColors.onPrimary,
        textStyle: const TextStyle(
          fontFamily: 'ThmanyahSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        elevation: 0,
      ),
    );

// Ghost / Outline Button — transparent fill, black border
final OutlinedButtonThemeData souqlyOutlinedButtonTheme =
    OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: SouqlyColors.ghostText,
        side: const BorderSide(color: SouqlyColors.ghostBorder, width: 1.5),
        textStyle: const TextStyle(
          fontFamily: 'ThmanyahSans',
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );

// Text / Link Button
final TextButtonThemeData souqlyTextButtonTheme = TextButtonThemeData(
  style: TextButton.styleFrom(
    foregroundColor: SouqlyColors.primary,
    textStyle: const TextStyle(
      fontFamily: 'ThmanyahSans',
      fontWeight: FontWeight.w600,
      fontSize: 14,
    ),
  ),
);

// ------------------------------------------------------------
//  5. INPUT / FORM DECORATION THEME
// ------------------------------------------------------------
const InputDecorationTheme souqlyInputDecorationTheme = InputDecorationTheme(
  filled: true,
  fillColor: SouqlyColors.secondary,
  hintStyle: TextStyle(
    fontFamily: 'ThmanyahSans',
    fontSize: 14,
    color: SouqlyColors.inputEmpty,
  ),
  labelStyle: TextStyle(
    fontFamily: 'ThmanyahSans',
    fontSize: 14,
    color: SouqlyColors.border,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: SouqlyColors.border, width: 1),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: SouqlyColors.border, width: 1),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: SouqlyColors.inputFocus, width: 2),
  ),
  errorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: SouqlyColors.inputError, width: 1.5),
  ),
  focusedErrorBorder: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(8)),
    borderSide: BorderSide(color: SouqlyColors.inputError, width: 2),
  ),
  errorStyle: TextStyle(
    fontFamily: 'ThmanyahSans',
    fontSize: 12,
    color: SouqlyColors.inputError,
  ),
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
);

// ------------------------------------------------------------
//  6. BOTTOM NAVIGATION BAR THEME
//  Nav items: Home, Saved, Add Listing, Messages, Account
// ------------------------------------------------------------
const BottomNavigationBarThemeData souqlyBottomNavTheme =
    BottomNavigationBarThemeData(
      backgroundColor: SouqlyColors.secondary,
      selectedItemColor: SouqlyColors.primary,
      unselectedItemColor: SouqlyColors.border,
      selectedLabelStyle: TextStyle(
        fontFamily: 'ThmanyahSans',
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'ThmanyahSans',
        fontSize: 11,
        fontWeight: FontWeight.w400,
      ),
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    );

// ------------------------------------------------------------
//  7. APP BAR THEME
// ------------------------------------------------------------
const AppBarTheme souqlyAppBarTheme = AppBarTheme(
  backgroundColor: SouqlyColors.secondary,
  foregroundColor: SouqlyColors.primary,
  elevation: 0,
  shadowColor: Colors.transparent,
  surfaceTintColor: Colors.transparent,
  titleTextStyle: TextStyle(
    fontFamily: 'ThmanyahSans',
    fontWeight: FontWeight.w600,
    fontSize: 18,
    color: SouqlyColors.primary,
  ),
  iconTheme: IconThemeData(color: SouqlyColors.primary, size: 22),
  centerTitle: false,
);

// ------------------------------------------------------------
//  8. CARD THEME (used for listing cards)
// ------------------------------------------------------------
const CardThemeData souqlyCardTheme = CardThemeData(
  color: SouqlyColors.secondary,
  shadowColor: SouqlyColors.border,
  elevation: 2,
  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(12)),
    side: BorderSide(color: SouqlyColors.inputEmpty, width: 0.5),
  ),
  clipBehavior: Clip.antiAlias,
);

// ------------------------------------------------------------
//  9. ICON THEME
// ------------------------------------------------------------
const IconThemeData souqlyIconTheme = IconThemeData(
  color: SouqlyColors.primary,
  size: 22,
);

// ------------------------------------------------------------
//  10. CHIP THEME (for category chips)
// ------------------------------------------------------------
final ChipThemeData souqlyChipTheme = ChipThemeData(
  backgroundColor: SouqlyColors.background,
  selectedColor: SouqlyColors.primary,
  disabledColor: SouqlyColors.background,
  labelStyle: const TextStyle(
    fontFamily: 'ThmanyahSans',
    fontSize: 13,
    color: SouqlyColors.text,
  ),
  secondaryLabelStyle: const TextStyle(
    fontFamily: 'ThmanyahSans',
    fontSize: 13,
    color: SouqlyColors.secondary,
  ),
  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
    side: const BorderSide(color: SouqlyColors.border, width: 0.5),
  ),
);

// ------------------------------------------------------------
//  11. DIVIDER THEME
// ------------------------------------------------------------
const DividerThemeData souqlyDividerTheme = DividerThemeData(
  color: SouqlyColors.inputEmpty,
  thickness: 1,
  space: 1,
);

// ------------------------------------------------------------
//  12. SWITCH THEME (for toggle inputs like Error/Focus)
// ------------------------------------------------------------
final SwitchThemeData souqlySwitchTheme = SwitchThemeData(
  thumbColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return SouqlyColors.secondary;
    return SouqlyColors.border;
  }),
  trackColor: WidgetStateProperty.resolveWith((states) {
    if (states.contains(WidgetState.selected)) return SouqlyColors.primary;
    return SouqlyColors.background;
  }),
);

// ------------------------------------------------------------
//  13. FLOATING ACTION BUTTON (Add Listing "+")
// ------------------------------------------------------------
const FloatingActionButtonThemeData souqlyFabTheme =
    FloatingActionButtonThemeData(
      backgroundColor: SouqlyColors.primary,
      foregroundColor: SouqlyColors.secondary,
      elevation: 4,
      shape: CircleBorder(),
    );

// ------------------------------------------------------------
//  14. COLOR SCHEME
// ------------------------------------------------------------
const ColorScheme souqlyColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: SouqlyColors.primary,
  onPrimary: SouqlyColors.onPrimary,
  secondary: SouqlyColors.border,
  onSecondary: SouqlyColors.secondary,
  error: SouqlyColors.error,
  onError: SouqlyColors.onError,
  surface: SouqlyColors.surface,
  onSurface: SouqlyColors.onSurface,
);

// ------------------------------------------------------------
//  15. MASTER THEME — plug this into MaterialApp
// ------------------------------------------------------------
final ThemeData souqlyTheme = ThemeData(
  useMaterial3: true,
  colorScheme: souqlyColorScheme,
  scaffoldBackgroundColor: SouqlyColors.secondary,
  fontFamily: 'ThmanyahSans',
  textTheme: souqlyTextTheme,
  appBarTheme: souqlyAppBarTheme,
  elevatedButtonTheme: souqlyElevatedButtonTheme,
  outlinedButtonTheme: souqlyOutlinedButtonTheme,
  textButtonTheme: souqlyTextButtonTheme,
  inputDecorationTheme: souqlyInputDecorationTheme,
  bottomNavigationBarTheme: souqlyBottomNavTheme,
  cardTheme: souqlyCardTheme,
  iconTheme: souqlyIconTheme,
  chipTheme: souqlyChipTheme,
  dividerTheme: souqlyDividerTheme,
  switchTheme: souqlySwitchTheme,
  floatingActionButtonTheme: souqlyFabTheme,
);

// ============================================================
//  HOW TO USE
//  In your main.dart:
//
//  import 'souqly_theme.dart';
//
//  MaterialApp(
//    title: 'Sello',
//    theme: souqlyTheme,
//    // For RTL (Arabic) support:
//    locale: const Locale('ar'),
//    supportedLocales: const [Locale('ar'), Locale('en')],
//    builder: (context, child) => Directionality(
//      textDirection: TextDirection.rtl,
//      child: child!,
//    ),
//    home: const HomeScreen(),
//  );
//
//  PUBSPEC.YAML — add Cairo font:
//  dependencies:
//    fonts: ThmanyahSans under assets/fonts/
//
//  OR manually:
//  flutter:
//    fonts:
//      - family: Cairo
//        fonts:
//          - asset: assets/fonts/Cairo-Regular.ttf
//            weight: 400
//          - asset: assets/fonts/Cairo-SemiBold.ttf
//            weight: 600
// ============================================================
