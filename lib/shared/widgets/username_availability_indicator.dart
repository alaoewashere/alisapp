import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/username_utils.dart';

class UsernameAvailabilityIndicator extends StatelessWidget {
  const UsernameAvailabilityIndicator({super.key, required this.state});

  final UsernameState state;

  @override
  Widget build(BuildContext context) {
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
              'جاري التحقق...',
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
              'متاح ✓',
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
              'مستخدم بالفعل ✗',
              style: AppFonts.cairo(fontSize: 13, color: Colors.red),
            ),
          ],
        );
      case UsernameState.tooShort:
        return Text(
          '3–20 حرفاً: أحرف إنجليزية وأرقام و _ فقط',
          textAlign: TextAlign.center,
          style: AppFonts.cairo(fontSize: 13, color: const Color(0xFF888888)),
        );
      case UsernameState.idle:
        return const SizedBox.shrink();
    }
  }
}
