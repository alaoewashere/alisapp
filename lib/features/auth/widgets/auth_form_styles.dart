import 'package:flutter/material.dart';

import '../../../theme/app_form_fields.dart';
import '../../../theme/app_text_styles.dart';
import '../../../core/constants/app_colors.dart';

abstract final class AuthFormStyles {
  /// Legacy pill radius for OTP boxes, outlined buttons, etc.
  static const pillRadius = 30.0;

  /// Shared field fill — same as [AppFormDecorations.fieldFill].
  static const fieldFill = AppFormDecorations.fieldFill;

  static TextStyle fieldLabel(BuildContext context) => AppTextStyles.subheading;

  static InputDecoration fieldDecoration({
    required String hintText,
    EdgeInsetsGeometry? contentPadding,
    Widget? suffixIcon,
  }) {
    return AppFormDecorations.underline(
      hintText: hintText,
      suffix: suffixIcon,
    ).copyWith(
      contentPadding: contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.45),
      disabledForegroundColor: Colors.white.withValues(alpha: 0.85),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      textStyle: AppTextStyles.button,
    );
  }
}

class AuthPillField extends StatelessWidget {
  const AuthPillField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldGroupLabel(label: label, required: true),
        AppFormFieldGroup(
          children: [
            TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              obscureText: obscureText,
              textDirection: textDirection,
              textAlign: textAlign,
              textCapitalization: textCapitalization,
              autofillHints: autofillHints,
              style: AppTextStyles.input,
              validator: validator,
              decoration: AuthFormStyles.fieldDecoration(
                hintText: hintText ?? '',
                suffixIcon: suffixIcon,
              ),
              onChanged: onChanged,
            ),
          ],
        ),
      ],
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: AuthFormStyles.primaryButtonStyle(),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.borderLight.withValues(alpha: 0.9),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          child: Divider(
            color: AppColors.borderLight.withValues(alpha: 0.9),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
