import 'package:flutter/material.dart';

import '../../theme/app_form_fields.dart';
import '../../theme/app_text_styles.dart';
import 'app_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  AppTheme._();

  /// Dark "fintech" theme. Name kept as [light] for back-compat with callers.
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.volt,
      brightness: Brightness.dark,
      primary: AppColors.volt,
      onPrimary: AppColors.canvas,
      secondary: AppColors.volt,
      onSecondary: AppColors.canvas,
      surface: AppColors.fieldCarbon,
    ).copyWith(
      onSurface: AppColors.pureWhite,
      onSurfaceVariant: AppColors.textMuted,
      outline: AppColors.glassBorder,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.sansFamily,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
    );

    return base.copyWith(
      textTheme: AppTextStyles.textTheme(colorScheme),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.pureWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 56,
        iconTheme: const IconThemeData(color: AppColors.pureWhite),
        titleTextStyle: AppTextStyles.subheading.copyWith(fontSize: 17),
      ),
      inputDecorationTheme: AppFormDecorations.inputTheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.volt,
          foregroundColor: AppColors.canvas,
          textStyle: AppTextStyles.button,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.volt,
          foregroundColor: AppColors.canvas,
          textStyle: AppTextStyles.button,
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.volt,
          textStyle: AppTextStyles.button.copyWith(color: AppColors.volt),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.pureWhite,
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
          textStyle: AppTextStyles.button.copyWith(color: AppColors.pureWhite),
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.fieldCarbon,
        shadowColor: AppColors.microShadow,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.glassBorder, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.fieldCarbon,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.fieldCarbon,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.volt,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.volt,
        foregroundColor: AppColors.canvas,
        elevation: 4,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.volt,
        selectionColor: Color(0x4DD4FF3A),
        selectionHandleColor: AppColors.volt,
      ),
    );
  }
}
