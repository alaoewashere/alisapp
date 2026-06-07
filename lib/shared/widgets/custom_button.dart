import 'package:flutter/material.dart';

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
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
