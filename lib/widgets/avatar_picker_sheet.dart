import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/dicebear_avatars.dart';
import '../shared/widgets/dicebear_avatar_cell.dart';

Future<void> showAvatarPickerSheet(
  BuildContext context, {
  required String? currentSeed,
  required ValueChanged<String> onSelected,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AvatarPickerSheet(
      currentSeed: currentSeed,
      onSelected: onSelected,
    ),
  );
}

class AvatarPickerSheet extends ConsumerStatefulWidget {
  const AvatarPickerSheet({
    super.key,
    required this.currentSeed,
    required this.onSelected,
  });

  final String? currentSeed;
  final ValueChanged<String> onSelected;

  @override
  ConsumerState<AvatarPickerSheet> createState() => _AvatarPickerSheetState();
}

class _AvatarPickerSheetState extends ConsumerState<AvatarPickerSheet> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = DiceBearAvatars.resolveSeed(widget.currentSeed);
  }

  void _pick(String seed) {
    setState(() => _selected = seed);
    widget.onSelected(seed);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.6;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              strings.chooseAvatarTitle,
              style: AppFonts.cairo(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              itemCount: DiceBearAvatars.seeds.length,
              itemBuilder: (context, index) {
                final seed = DiceBearAvatars.seeds[index];
                return DiceBearAvatarCell(
                  seed: seed,
                  selected: seed == _selected,
                  onTap: () => _pick(seed),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
