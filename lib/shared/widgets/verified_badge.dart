import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Volt Green verified checkmark badge (بروفايل موثق).
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: AppColors.volt,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        color: AppColors.canvas,
        size: size * 0.65,
      ),
    );
  }
}

/// Inline helper matching spec naming.
Widget verifiedBadge({double size = 16}) => VerifiedBadge(size: size);
