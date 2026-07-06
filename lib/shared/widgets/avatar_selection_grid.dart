import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';
import '../../core/l10n/l10n_provider.dart';
import 'dicebear_avatar_cell.dart';

/// Wrapped grid of selectable DiceBear avatars for profile setup.
class AvatarSelectionGrid extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final activeSeed = DiceBearAvatars.resolveSeed(selectedSeed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          strings.chooseDefaultAvatar,
          style: AppFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          strings.orUploadPhotoHint,
          style: AppFonts.cairo(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final seed in DiceBearAvatars.seeds)
              DiceBearAvatarCell(
                seed: seed,
                selected: activeSeed == seed,
                onTap: enabled ? () => onSelected(seed) : () {},
              ),
          ],
        ),
      ],
    );
  }
}
