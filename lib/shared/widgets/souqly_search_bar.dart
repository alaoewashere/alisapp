import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_decorations.dart';
import 'glass_container.dart';

/// Tappable search field — matches home glass surfaces (Cupertino Glass DNA).
class SouqlySearchBar extends StatelessWidget {
  const SouqlySearchBar({
    super.key,
    required this.hint,
    required this.onTap,
  });

  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hintStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: AppColors.textMuted,
        );

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
