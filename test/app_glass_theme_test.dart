import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/core/theme/app_decorations.dart';

void main() {
  group('Dark fintech design tokens', () {
    test('AppColors match the dark fintech palette', () {
      // Volt Green is the primary accent.
      expect(AppColors.primary, const Color(0xFFD4FF3A));
      expect(AppColors.accent, const Color(0xFFD4FF3A));
      // Deep Canvas is the scaffold/background color.
      expect(AppColors.background, const Color(0xFF131315));
      // Field Carbon is the card/surface color.
      expect(AppColors.surface, const Color(0xFF18181A));
      // Primary text on dark surfaces is Pure White.
      expect(AppColors.textDark, const Color(0xFFFFFFFF));
    });

    test('AppDecorations uses radius 18 for cards and 30 for nav', () {
      expect(AppDecorations.cardRadius, 18);
      expect(AppDecorations.navRadius, 30);
      expect(AppDecorations.glassCard().borderRadius, BorderRadius.circular(18));
    });
  });
}
