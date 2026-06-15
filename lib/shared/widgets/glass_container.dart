import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_decorations.dart';

/// Frosted glass surface — Cupertino Glass from souqly-redesign-studio.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.radius = AppDecorations.cardRadius,
    this.blur = 12,
    this.fill = AppColors.glassFill,
    this.borderColor = AppColors.glassBorder,
    this.padding,
    this.margin,
    this.onTap,
    this.onLongPress,
    this.enableTapHaptics = true,
    this.enableLongPressHaptics = true,
  });

  final Widget child;
  final double radius;
  final double blur;
  final Color fill;
  final Color borderColor;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enableTapHaptics;
  final bool enableLongPressHaptics;

  @override
  Widget build(BuildContext context) {
    Widget content = ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: fill,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 0.5),
            boxShadow: AppDecorations.cardShadow,
          ),
          child: padding != null ? Padding(padding: padding!, child: child) : child,
        ),
      ),
    );

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    if (onTap != null || onLongPress != null) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap == null
              ? null
              : () {
                  if (enableTapHaptics) HapticFeedback.selectionClick();
                  onTap!();
                },
          onLongPress: onLongPress == null
              ? null
              : () {
                  if (enableLongPressHaptics) HapticFeedback.mediumImpact();
                  onLongPress!();
                },
          borderRadius: BorderRadius.circular(radius),
          child: content,
        ),
      );
    }

    return content;
  }
}
