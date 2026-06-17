import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'app_text_styles.dart';

/// Underline-style inputs and grouped form layout (Airbnb / iOS Settings pattern).
abstract final class AppFormDecorations {
  static const fieldFill = AppColors.fieldCarbon;
  static const double _radius = 14;

  static OutlineInputBorder _border(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(_radius),
        borderSide: BorderSide(color: color, width: width),
      );

  static InputDecoration underline({
    String? hintText,
    String? labelText,
    Widget? suffix,
    String? suffixText,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: AppTextStyles.hint,
      labelStyle: AppTextStyles.caption,
      filled: true,
      fillColor: fieldFill,
      border: _border(AppColors.glassBorder, 1),
      enabledBorder: _border(AppColors.glassBorder, 1),
      focusedBorder: _border(AppColors.volt, 2),
      errorBorder: _border(AppColors.rejected, 1.5),
      focusedErrorBorder: _border(AppColors.rejected, 2),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffix: suffix,
      suffixText: suffixText,
      suffixStyle: AppTextStyles.caption,
      alignLabelWithHint: alignLabelWithHint,
    );
  }

  static InputDecorationTheme get inputTheme => InputDecorationTheme(
    hintStyle: AppTextStyles.hint,
    labelStyle: AppTextStyles.caption,
    filled: true,
    fillColor: fieldFill,
    border: _border(AppColors.glassBorder, 1),
    enabledBorder: _border(AppColors.glassBorder, 1),
    focusedBorder: _border(AppColors.volt, 2),
    errorBorder: _border(AppColors.rejected, 1.5),
    focusedErrorBorder: _border(AppColors.rejected, 2),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

/// White rounded group wrapping multiple underline fields.
class AppFormFieldGroup extends StatelessWidget {
  const AppFormFieldGroup({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }
}

/// Label row above a field group with optional required dot.
class AppFieldGroupLabel extends StatelessWidget {
  const AppFieldGroupLabel({
    super.key,
    required this.label,
    this.required = false,
    this.optional = false,
  });

  final String label;
  final bool required;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Text(label, style: AppTextStyles.subheading),
          if (required) ...[
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
          if (optional) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('اختياري', style: AppTextStyles.caption),
            ),
          ],
        ],
      ),
    );
  }
}

class AppFieldCharCounter extends StatelessWidget {
  const AppFieldCharCounter({
    super.key,
    required this.current,
    required this.max,
  });

  final int current;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, right: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          '$current/$max',
          style: AppTextStyles.counter,
          textAlign: TextAlign.left,
        ),
      ),
    );
  }
}

class AppListingFormSectionDivider extends StatelessWidget {
  const AppListingFormSectionDivider({
    super.key,
    this.label = 'تفاصيل الإعلان',
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.borderLight, thickness: 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(label, style: AppTextStyles.caption),
          ),
          const Expanded(
            child: Divider(color: AppColors.borderLight, thickness: 1),
          ),
        ],
      ),
    );
  }
}

/// Thin divider between fields inside a group.
class AppFormFieldDivider extends StatelessWidget {
  const AppFormFieldDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppColors.borderLight,
      indent: 16,
      endIndent: 16,
    );
  }
}
