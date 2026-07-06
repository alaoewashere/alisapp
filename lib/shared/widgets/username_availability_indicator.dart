import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/utils/username_utils.dart';

class UsernameAvailabilityIndicator extends ConsumerWidget {
  const UsernameAvailabilityIndicator({super.key, required this.state});

  final UsernameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);

    switch (state) {
      case UsernameState.checking:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 8),
            Text(
              strings.usernameChecking,
              style: AppFonts.cairo(
                fontSize: 13,
                color: const Color(0xFF888888),
              ),
            ),
          ],
        );
      case UsernameState.available:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: AppColors.primary, size: 16),
            const SizedBox(width: 6),
            Text(
              strings.usernameAvailable,
              style: AppFonts.cairo(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      case UsernameState.taken:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cancel, color: Colors.red, size: 16),
            const SizedBox(width: 6),
            Text(
              strings.usernameTaken,
              style: AppFonts.cairo(fontSize: 13, color: Colors.red),
            ),
          ],
        );
      case UsernameState.tooShort:
        return Text(
          strings.usernameRules,
          textAlign: TextAlign.center,
          style: AppFonts.cairo(fontSize: 13, color: const Color(0xFF888888)),
        );
      case UsernameState.idle:
        return const SizedBox.shrink();
    }
  }
}
