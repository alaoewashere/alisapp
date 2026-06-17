import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Standard back control — Field Carbon circle, white border, white arrow.
class AppBackButton extends StatelessWidget {
  const AppBackButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  static const _borderColor = Color(0x20FFFFFF);

  static ButtonStyle style() => IconButton.styleFrom(
        backgroundColor: AppColors.fieldCarbon,
        foregroundColor: AppColors.pureWhite,
        disabledBackgroundColor: AppColors.fieldCarbon,
        disabledForegroundColor: AppColors.textMuted,
        fixedSize: const Size(40, 40),
        minimumSize: const Size(40, 40),
        maximumSize: const Size(40, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(
          side: BorderSide(color: _borderColor),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      style: style(),
      icon: const Icon(Icons.arrow_back, size: 20),
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
    );
  }
}
