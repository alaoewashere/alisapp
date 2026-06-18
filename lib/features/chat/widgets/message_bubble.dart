import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/chat_date_utils.dart';
import '../../../shared/models/message_model.dart';
import '../../../widgets/user_avatar.dart';

const _largeRadius = 20.0;
const _smallRadius = 6.0;

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.otherUserAvatarSeed,
  });

  final MessageModel message;
  final String currentUserId;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String? otherUserAvatarSeed;

  bool get _isMine => message.isMine(currentUserId);

  @override
  Widget build(BuildContext context) {
    if (_isMine) {
      return _SentBubble(
        message: message,
        isFirstInGroup: isFirstInGroup,
        isLastInGroup: isLastInGroup,
      );
    }
    return _ReceivedBubble(
      message: message,
      isFirstInGroup: isFirstInGroup,
      isLastInGroup: isLastInGroup,
      otherUserAvatarSeed: otherUserAvatarSeed,
    );
  }
}

BorderRadius _sentBorderRadius({
  required bool isFirstInGroup,
  required bool isLastInGroup,
}) {
  if (isFirstInGroup && isLastInGroup) {
    return const BorderRadius.only(
      topLeft: Radius.circular(_largeRadius),
      topRight: Radius.circular(_largeRadius),
      bottomLeft: Radius.circular(_largeRadius),
      bottomRight: Radius.circular(_smallRadius),
    );
  }
  return BorderRadius.only(
    topLeft: Radius.circular(isFirstInGroup ? _largeRadius : _smallRadius),
    topRight: Radius.circular(isFirstInGroup ? _largeRadius : _smallRadius),
    bottomLeft: Radius.circular(isLastInGroup ? _largeRadius : _smallRadius),
    bottomRight: const Radius.circular(_smallRadius),
  );
}

BorderRadius _receivedBorderRadius({
  required bool isFirstInGroup,
  required bool isLastInGroup,
}) {
  if (isFirstInGroup && isLastInGroup) {
    return const BorderRadius.only(
      topLeft: Radius.circular(_smallRadius),
      topRight: Radius.circular(_largeRadius),
      bottomLeft: Radius.circular(_largeRadius),
      bottomRight: Radius.circular(_largeRadius),
    );
  }
  return BorderRadius.only(
    topLeft: Radius.circular(isFirstInGroup ? _smallRadius : _smallRadius),
    topRight: Radius.circular(isFirstInGroup ? _largeRadius : _smallRadius),
    bottomLeft: Radius.circular(isLastInGroup ? _largeRadius : _smallRadius),
    bottomRight: Radius.circular(isLastInGroup ? _largeRadius : _smallRadius),
  );
}

EdgeInsets _bubbleMargin({
  required bool isSent,
  required bool isLastInGroup,
}) {
  final bottom = isLastInGroup ? 10.0 : 3.0;
  if (isSent) {
    return EdgeInsets.only(bottom: bottom, right: 16, left: 60);
  }
  return EdgeInsets.only(bottom: bottom, right: 60);
}

class _SentBubble extends StatelessWidget {
  const _SentBubble({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final MessageModel message;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  bool get _hasImage =>
      message.imageUrl != null && message.imageUrl!.isNotEmpty;

  bool get _hasText => message.content.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final timeString = formatMessageTime(message.createdAt);
    final opacity = message.isPending ? 0.75 : 1.0;
    final imageOnly = _hasImage && !_hasText;

    return Opacity(
      opacity: opacity,
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: _bubbleMargin(isSent: true, isLastInGroup: isLastInGroup),
          padding: imageOnly
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: AppColors.chatSent,
            borderRadius: _sentBorderRadius(
              isFirstInGroup: isFirstInGroup,
              isLastInGroup: isLastInGroup,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_hasImage)
                _MessageImage(
                  url: message.imageUrl!,
                  borderRadius: _sentBorderRadius(
                    isFirstInGroup: isFirstInGroup,
                    isLastInGroup: isLastInGroup,
                  ),
                  imageOnly: imageOnly,
                ),
              if (_hasText)
                Padding(
                  padding: imageOnly
                      ? EdgeInsets.zero
                      : EdgeInsets.only(top: _hasImage ? 8 : 0),
                  child: Text(
                    message.content,
                    style: AppFonts.tajawal(
                      fontSize: 14.5,
                      color: AppColors.surface,
                      height: 1.5,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              if (!imageOnly) ...[
                const SizedBox(height: 4),
                Padding(
                  padding: _hasImage && _hasText
                      ? const EdgeInsets.only(bottom: 4)
                      : EdgeInsets.zero,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeString,
                        style: AppFonts.inter(
                          fontSize: 10,
                          color: AppColors.surface.withValues(alpha: 0.65),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 13,
                        color: message.isRead
                            ? AppColors.chatReadReceipt
                            : AppColors.surface.withValues(alpha: 0.65),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ReceivedBubble extends StatelessWidget {
  const _ReceivedBubble({
    required this.message,
    required this.isFirstInGroup,
    required this.isLastInGroup,
    this.otherUserAvatarSeed,
  });

  final MessageModel message;
  final bool isFirstInGroup;
  final bool isLastInGroup;
  final String? otherUserAvatarSeed;

  bool get _hasImage =>
      message.imageUrl != null && message.imageUrl!.isNotEmpty;

  bool get _hasText => message.content.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final timeString = formatMessageTime(message.createdAt);
    final imageOnly = _hasImage && !_hasText;
    final showAvatar = isLastInGroup;

    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        textDirection: TextDirection.ltr,
        children: [
          SizedBox(
            width: 28,
            child: showAvatar
                ? UserAvatar(avatarSeed: otherUserAvatarSeed, size: 28)
                : null,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Container(
              margin: _bubbleMargin(isSent: false, isLastInGroup: isLastInGroup),
              padding: imageOnly
                  ? EdgeInsets.zero
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: _receivedBorderRadius(
                  isFirstInGroup: isFirstInGroup,
                  isLastInGroup: isLastInGroup,
                ),
                border: Border.all(
                  color: AppColors.chatBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_hasImage)
                    _MessageImage(
                      url: message.imageUrl!,
                      borderRadius: _receivedBorderRadius(
                        isFirstInGroup: isFirstInGroup,
                        isLastInGroup: isLastInGroup,
                      ),
                      imageOnly: imageOnly,
                    ),
                  if (_hasText)
                    Padding(
                      padding: EdgeInsets.only(top: _hasImage ? 8 : 0),
                      child: Text(
                        message.content,
                        style: AppFonts.tajawal(
                          fontSize: 14.5,
                          color: AppColors.chatTextDark,
                          height: 1.5,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  if (!imageOnly) ...[
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: AppFonts.inter(
                        fontSize: 10,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageImage extends StatelessWidget {
  const _MessageImage({
    required this.url,
    required this.borderRadius,
    this.imageOnly = false,
  });

  final String url;
  final BorderRadius borderRadius;
  final bool imageOnly;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: imageOnly ? borderRadius : BorderRadius.circular(18),
      child: CachedNetworkImage(
        imageUrl: url,
        width: 200,
        height: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}

class ChatDateSeparator extends StatelessWidget {
  const ChatDateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          formatChatDateSeparator(date),
          style: AppFonts.tajawal(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class ChatListingThumb extends StatelessWidget {
  const ChatListingThumb({super.key, this.url, this.size = 40});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(Icons.image_outlined, size: 18),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
      ),
    );
  }
}
