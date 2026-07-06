import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

import '../../../core/l10n/l10n_provider.dart';

/// «عرض الكل» link — matches the Home categories section header style.
class HomeSectionViewAllLink extends StatelessWidget {
  const HomeSectionViewAllLink({
    super.key,
    required this.onPressed,
  });

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        context.l10n.viewAll,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
