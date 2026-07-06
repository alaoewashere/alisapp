import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/utils/chat_date_utils.dart';
import '../../../shared/models/conversation_model.dart';
import 'chat_user_avatar.dart';
import 'message_bubble.dart';

/// Modern card-style row for a single conversation in the inbox.
class ConversationTile extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final localeCode = ref.watch(categoryLocaleCodeProvider);
    final hasUnread = conversation.unreadCount > 0;
    final time = conversation.lastMessageTime ?? conversation.createdAt;
    final lastTime = conversation.lastMessageTime ?? conversation.createdAt;
    final isOnline = DateTime.now().difference(lastTime).inMinutes < 30;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.fieldCarbon,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
            boxShadow: const [
              BoxShadow(
                color: AppColors.microShadow,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ChatUserAvatar(
                  avatarSeed: conversation.otherUserAvatarSeed,
                  size: 48,
                  online: isOnline,
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
                              conversation.otherUserName ?? strings.defaultUser,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.cairo(
                                fontSize: 14,
                                fontWeight: hasUnread
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: AppColors.textDark,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            formatConversationTime(
                              time,
                              strings,
                              languageCode: localeCode,
                            ),
                            style: AppFonts.cairo(
                              fontSize: 10,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              conversation.lastMessage ??
                                  strings.startChatDefault,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppFonts.tajawal(
                                fontSize: 13,
                                fontWeight:
                                    hasUnread ? FontWeight.w600 : FontWeight.normal,
                                color: hasUnread
                                    ? AppColors.textDark
                                    : AppColors.textMuted,
                              ),
                            ),
                          ),
                          if (hasUnread) ...[
                            const SizedBox(width: 8),
                            _UnreadBadge(count: conversation.unreadCount),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (conversation.listingImage != null &&
                    conversation.listingImage!.isNotEmpty) ...[
                  const SizedBox(width: 10),
                  ChatListingThumb(url: conversation.listingImage, size: 36),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count > 99 ? '99+' : '$count';
    return Container(
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: const BoxDecoration(
        color: AppColors.approved,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: AppFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
