import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../widgets/user_avatar.dart';

/// Circular user avatar with optional online indicator.
class ChatUserAvatar extends StatelessWidget {
  const ChatUserAvatar({
    super.key,
    this.avatarSeed,
    this.size = 48,
    this.online = false,
    this.borderColor,
  });

  final String? avatarSeed;
  final double size;
  final bool online;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final ring = borderColor ?? AppColors.accent.withValues(alpha: 0.35);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: ring, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: UserAvatar(avatarSeed: avatarSeed, size: size),
        ),
        if (online)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: AppColors.approved,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact avatar + name for the active-users horizontal strip.
class ActiveUserChip extends StatelessWidget {
  const ActiveUserChip({
    super.key,
    required this.name,
    this.avatarSeed,
    this.online = true,
    this.onTap,
  });

  final String name;
  final String? avatarSeed;
  final bool online;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ChatUserAvatar(
              avatarSeed: avatarSeed,
              size: 44,
              online: online,
              borderColor: AppColors.accent.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 6),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.cairo(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
