import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_decorations.dart';
import 'glass_container.dart';

/// Home search field — editable for in-feed filtering, or tappable to navigate.
class SouqlySearchBar extends StatelessWidget {
  const SouqlySearchBar({
    super.key,
    required this.hint,
    this.onTap,
    this.controller,
    this.onChanged,
    this.textInputAction = TextInputAction.search,
    this.onSubmitted,
  });

  final String hint;
  final VoidCallback? onTap;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;

  bool get _isEditable => onChanged != null || controller != null;

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        );

    if (_isEditable) {
      return GlassContainer(
        radius: AppDecorations.cardRadius,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                key: controller != null ? const Key('home_search_field') : null,
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: textInputAction,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textDark,
                    ),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle: hintStyle,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            Icon(
              Icons.search_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      );
    }

    return GlassContainer(
      radius: AppDecorations.cardRadius,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: hintStyle,
            ),
          ),
          Icon(
            Icons.search_rounded,
            color: AppColors.textMuted,
            size: 20,
          ),
        ],
      ),
    );
  }
}
