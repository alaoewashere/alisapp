import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
              style: GoogleFonts.cairo(
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
              style: GoogleFonts.cairo(
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
              'هذا الاسم محجوز',
              style: GoogleFonts.cairo(fontSize: 13, color: Colors.red),
            ),
          ],
        );
      case UsernameState.tooShort:
        return Text(
          'يجب أن يكون 3 أحرف على الأقل',
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(fontSize: 13, color: const Color(0xFF888888)),
        );
      case UsernameState.idle:
        return const SizedBox.shrink();
    }
  }
}
