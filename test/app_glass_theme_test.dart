import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/app_colors.dart';
import 'package:my_app/core/theme/app_decorations.dart';

void main() {
  group('Cupertino Glass design tokens', () {
    test('AppColors match souqly-redesign-studio cupertino-glass theme', () {
      expect(AppColors.primary, const Color(0xFF005F54));
      expect(AppColors.accent, const Color(0xFF00897B));
      expect(AppColors.background, const Color(0xFFF0F2F5));
      expect(AppColors.textDark, const Color(0xFF1D1D1F));
    });

    test('AppDecorations uses radius 20 for cards and 30 for nav', () {
      expect(AppDecorations.cardRadius, 20);
      expect(AppDecorations.navRadius, 30);
      expect(AppDecorations.glassCard().borderRadius, BorderRadius.circular(20));
    });
  });
}
