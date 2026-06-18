import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';
import 'dicebear_avatar_cell.dart';

/// Wrapped grid of selectable DiceBear avatars for profile setup.
class AvatarSelectionGrid extends StatelessWidget {
  const AvatarSelectionGrid({
    super.key,
    required this.selectedSeed,
    required this.onSelected,
    this.enabled = true,
  });

  final String? selectedSeed;
  final ValueChanged<String> onSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final activeSeed = DiceBearAvatars.resolveSeed(selectedSeed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختر صورة افتراضية',
          style: AppFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'أو ارفع صورتك من الكاميرا / المعرض أعلاه',
          style: AppFonts.cairo(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final seed in DiceBearAvatars.seeds)
              Opacity(
                opacity: enabled ? 1 : 0.5,
                child: DiceBearAvatarCell(
                  seed: seed,
                  selected: seed == activeSeed,
                  onTap: enabled ? () => onSelected(seed) : () {},
                ),
              ),
          ],
        ),
      ],
    );
  }
}
