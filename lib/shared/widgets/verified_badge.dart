import 'package:flutter/material.dart';

/// Facebook-style blue verified checkmark badge.
class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key, this.size = 16});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.check,
        color: Colors.white,
        size: size * 0.65,
      ),
    );
  }
}

/// Inline helper matching spec naming.
Widget verifiedBadge({double size = 16}) => VerifiedBadge(size: size);
