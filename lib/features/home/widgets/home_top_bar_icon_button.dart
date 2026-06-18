import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Circular header icon — shared by favorites (leading) and heat map (actions).
class HomeTopBarIconButton extends StatelessWidget {
  const HomeTopBarIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;

  static const size = 40.0;
  static const iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final button = SizedBox(
      width: size,
      height: size,
      child: Icon(icon, size: iconSize, color: AppColors.textDark),
    );

    return Material(
      color: AppColors.fieldCarbon,
      shape: const CircleBorder(
        side: BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: tooltip != null
            ? Tooltip(message: tooltip!, child: button)
            : button,
      ),
    );
  }
}
