import 'package:flutter/material.dart';

import 'app_back_button.dart';

/// App bar with the standard [AppBackButton] as the default leading control.
class SelloAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SelloAppBar({
    super.key,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onBack,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.scrolledUnderElevation,
    this.surfaceTintColor,
    this.centerTitle,
    this.bottom,
    this.flexibleSpace,
    this.toolbarHeight,
    this.titleTextStyle,
    this.leadingWidth,
  });

  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onBack;
  final Widget? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final double? scrolledUnderElevation;
  final Color? surfaceTintColor;
  final bool? centerTitle;
  final PreferredSizeWidget? bottom;
  final Widget? flexibleSpace;
  final double? toolbarHeight;
  final TextStyle? titleTextStyle;
  final double? leadingWidth;

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight((toolbarHeight ?? kToolbarHeight) + bottomHeight);
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveLeading = leading;
    if (effectiveLeading == null && automaticallyImplyLeading) {
      effectiveLeading = AppBackButton(onPressed: onBack);
    }

    return AppBar(
      automaticallyImplyLeading: false,
      leading: effectiveLeading,
      leadingWidth: leadingWidth,
      title: title,
      actions: actions,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      scrolledUnderElevation: scrolledUnderElevation,
      surfaceTintColor: surfaceTintColor,
      centerTitle: centerTitle,
      bottom: bottom,
      flexibleSpace: flexibleSpace,
      toolbarHeight: toolbarHeight,
      titleTextStyle: titleTextStyle,
    );
  }
}
