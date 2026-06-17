import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: outlined ? AppColors.volt : AppColors.canvas,
            ),
          )
        : Text(label);

    if (icon != null) {
      if (outlined) {
        return OutlinedButton.icon(
          onPressed: loading ? null : onPressed,
          icon: Icon(icon),
          label: child,
        );
      }
      return FilledButton.icon(
        onPressed: loading ? null : onPressed,
        icon: Icon(icon),
        label: child,
      );
    }

    if (outlined) {
      return OutlinedButton(onPressed: loading ? null : onPressed, child: child);
    }
    return FilledButton(onPressed: loading ? null : onPressed, child: child);
  }
}
