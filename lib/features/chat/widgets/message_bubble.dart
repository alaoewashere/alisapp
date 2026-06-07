import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/chat_date_utils.dart';
import '../../../shared/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.currentUserId,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final MessageModel message;
  final String currentUserId;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  bool get _isMine => message.isMine(currentUserId);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = _isMine ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest;
    final fg = _isMine ? Colors.white : theme.colorScheme.onSurface;
    final timeColor = _isMine ? Colors.white70 : theme.colorScheme.outline;

    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(_isMine || !isLastInGroup ? 16 : 4),
      bottomRight: Radius.circular(!_isMine || !isLastInGroup ? 16 : 4),
    );

    return Padding(
      padding: EdgeInsets.only(
        top: isFirstInGroup ? 8 : 2,
        bottom: isLastInGroup ? 4 : 2,
      ),
      child: Row(
        mainAxisAlignment:
            _isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.sizeOf(context).width * 0.78,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: message.isPending ? bg.withValues(alpha: 0.7) : bg,
                borderRadius: radius,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      message.content,
                      style: TextStyle(color: fg, height: 1.35),
                      textDirection: TextDirection.rtl,
                    ),
                    if (isLastInGroup) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            formatMessageTime(message.createdAt),
                            style: TextStyle(fontSize: 11, color: timeColor),
                          ),
                          if (_isMine) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.isRead
                                  ? Icons.done_all
                                  : Icons.done,
                              size: 14,
                              color: message.isRead ? Colors.lightBlueAccent : timeColor,
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatDateSeparator extends StatelessWidget {
  const ChatDateSeparator({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formatChatDateSeparator(date),
            style: Theme.of(context).textTheme.labelSmall,
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
