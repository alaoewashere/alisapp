import 'package:flutter/material.dart';

/// Local Thmanyah font families bundled under [assets/fonts/].
abstract final class AppFonts {
  static const sansFamily = 'ThmanyahSans';
  static const serifDisplayFamily = 'ThmanyahSerifDisplay';
  static const serifTextFamily = 'ThmanyahSerifText';

  /// UI headings, buttons, labels (replaces Cairo).
  static TextStyle sans({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    TextOverflow? overflow,
    List<FontFeature>? fontFeatures,
  }) {
    return TextStyle(
      fontFamily: sansFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
      overflow: overflow,
      fontFeatures: fontFeatures,
    );
  }

  /// Long-form body copy (replaces Tajawal).
  static TextStyle serifText({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: serifTextFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  /// Display / emphasis / reference codes (replaces Roboto Mono).
  static TextStyle serifDisplay({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) {
    return TextStyle(
      fontFamily: serifDisplayFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
      fontStyle: fontStyle,
    );
  }

  /// Back-compat aliases for migrated Google Fonts call sites.
  static TextStyle cairo({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
    TextOverflow? overflow,
  }) =>
      sans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
        overflow: overflow,
      );

  static TextStyle tajawal({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      serifText(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  static TextStyle inter({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      sans(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  static TextStyle robotoMono({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
    FontStyle? fontStyle,
  }) =>
      serifDisplay(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
        decoration: decoration,
        fontStyle: fontStyle,
      );

  static TextTheme sansTextTheme(TextTheme base) {
    return base.apply(fontFamily: sansFamily);
  }

  static TextTheme cairoTextTheme(TextTheme base) => sansTextTheme(base);

  /// Arabic display title «سـوقك» — Thmanyah Serif Display Bold only.
  static TextStyle brandNameArDisplay({
    double? fontSize,
    Color? color,
    double? height,
    double? letterSpacing,
  }) =>
      serifDisplay(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: color,
        height: height,
        letterSpacing: letterSpacing,
      );
}
