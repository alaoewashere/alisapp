import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/currency_formatter.dart';
import '../../../shared/models/conversation_model.dart';

class ConversationTile extends StatelessWidget {
  const ConversationTile({
    super.key,
    required this.conversation,
    required this.onTap,
    required this.onLongPress,
  });

  final ConversationModel conversation;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasUnread = conversation.unreadCount > 0;
    final time = conversation.lastMessageTime ?? conversation.createdAt;

    return Material(
      color: hasUnread
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.08)
          : null,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundImage: conversation.otherUserAvatar != null
                        ? CachedNetworkImageProvider(
                            conversation.otherUserAvatar!,
                          )
                        : null,
                    child: conversation.otherUserAvatar == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: theme.colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.otherUserName ?? 'مستخدم',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight:
                                  hasUnread ? FontWeight.bold : FontWeight.w600,
                            ),
                          ),
                        ),
                        Text(
                          formatRelativeTimeAr(time),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    if (conversation.listingTitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        conversation.listingTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            conversation.lastMessage ?? 'ابدأ المحادثة',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight:
                                  hasUnread ? FontWeight.w600 : FontWeight.normal,
                              color: hasUnread
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.outline,
                            ),
                          ),
                        ),
                        if (hasUnread)
                          Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Center(
                              child: Text(
                                conversation.unreadCount > 99
                                    ? '99+'
                                    : '${conversation.unreadCount}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: conversation.listingImage != null
                    ? CachedNetworkImage(
                        imageUrl: conversation.listingImage!,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        width: 52,
                        height: 52,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: const Icon(Icons.storefront_outlined),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
