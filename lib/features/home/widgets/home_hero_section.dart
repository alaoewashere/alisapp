import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

/// Home header headline — blends with page gradient, no separate card surface.
class HomeHeroSection extends StatelessWidget {
  const HomeHeroSection({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'اشتري و بيع',
            style: theme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
              height: 1.2,
            ),
          ),
          Text(
            'بسهولة.',
            style: theme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'اعثر على أفضل العروض بين يديك',
            style: theme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
