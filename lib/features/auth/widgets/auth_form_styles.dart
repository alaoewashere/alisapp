import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:Sello/core/theme/app_fonts.dart';

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
      contentPadding:
          contentPadding ??
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  static ButtonStyle primaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.canvas,
      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.35),
      disabledForegroundColor: AppColors.canvas.withValues(alpha: 0.55),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      textStyle: AppTextStyles.button,
    );
  }

  static const _loginFieldRadius = 14.0;

  static OutlineInputBorder _loginBorder(Color color, double width) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(_loginFieldRadius),
        borderSide: BorderSide(color: color, width: width),
      );

  static const _loginFieldBorder = Color(0x15FFFFFF);

  /// Login / auth flat fields — Field Carbon, 15% white border, 1.5px Volt focus.
  static InputDecoration loginFieldDecoration({
    required String hintText,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: AppFonts.sans(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.pureWhite.withValues(alpha: 0.5),
      ),
      filled: true,
      fillColor: AppColors.fieldCarbon,
      border: _loginBorder(_loginFieldBorder, 1),
      enabledBorder: _loginBorder(_loginFieldBorder, 1),
      focusedBorder: _loginBorder(AppColors.volt, 1.5),
      errorBorder: _loginBorder(AppColors.rejected, 1.5),
      focusedErrorBorder: _loginBorder(AppColors.rejected, 1.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      suffixIcon: suffixIcon,
    );
  }

  static ButtonStyle loginPrimaryButtonStyle() {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.volt,
      foregroundColor: AppColors.canvas,
      disabledBackgroundColor: AppColors.volt.withValues(alpha: 0.35),
      disabledForegroundColor: AppColors.canvas.withValues(alpha: 0.55),
      minimumSize: const Size.fromHeight(52),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
    this.maxLength,
    this.inputFormatters,
    this.prefixText,
    this.prefixStyle,
    this.grouped = true,
    this.loginStyle = false,
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
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? prefixText;
  final TextStyle? prefixStyle;
  final bool grouped;
  final bool loginStyle;

  @override
  Widget build(BuildContext context) {
    final field = TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      obscureText: obscureText,
      textDirection: textDirection,
      textAlign: textAlign,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      cursorColor: loginStyle ? AppColors.volt : null,
      style: loginStyle
          ? AppFonts.sans(
              fontSize: 15,
              fontWeight: FontWeight.w400,
              color: AppColors.pureWhite,
            )
          : AppTextStyles.input,
      validator: validator,
      decoration: (loginStyle
              ? AuthFormStyles.loginFieldDecoration(
                  hintText: hintText ?? '',
                  suffixIcon: suffixIcon,
                )
              : AuthFormStyles.fieldDecoration(
                  hintText: hintText ?? '',
                  suffixIcon: suffixIcon,
                ))
          .copyWith(
        counterText: maxLength != null ? '' : null,
        prefixText: prefixText,
        prefixStyle: prefixStyle ?? AppTextStyles.caption,
      ),
      onChanged: onChanged,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppFieldGroupLabel(label: label, required: true),
        if (grouped)
          AppFormFieldGroup(children: [field])
        else
          field,
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
    this.loginStyle = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool loginStyle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        style: loginStyle
            ? AuthFormStyles.loginPrimaryButtonStyle()
            : AuthFormStyles.primaryButtonStyle(),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.canvas,
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
    final lineColor = AppColors.pureWhite.withValues(alpha: 0.15);

    return Row(
      children: [
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(label, style: AppTextStyles.caption),
        ),
        Expanded(
          child: Divider(
            color: lineColor,
            thickness: 1,
          ),
        ),
      ],
    );
  }
}
