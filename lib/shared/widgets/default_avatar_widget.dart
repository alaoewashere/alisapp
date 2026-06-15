import 'package:flutter/material.dart';

import '../../core/constants/default_avatars.dart';

/// Circular illustrated preset avatar (emoji + gradient background).
class DefaultAvatarWidget extends StatelessWidget {
  const DefaultAvatarWidget({
    super.key,
    required this.avatar,
    this.size = 104,
    this.selected = false,
    this.showLabel = false,
  });

  final DefaultAvatar avatar;
  final double size;
  final bool selected;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final emojiSize = size * 0.46;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: avatar.gradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: selected ? avatar.ringColor : Colors.transparent,
              width: selected ? 3 : 0,
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: avatar.ringColor.withValues(alpha: 0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(avatar.emoji, style: TextStyle(fontSize: emojiSize)),
        ),
        if (showLabel) ...[
          const SizedBox(height: 6),
          Text(
            avatar.labelAr,
            style: const TextStyle(fontSize: 10, color: Color(0xFF86868B)),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}
