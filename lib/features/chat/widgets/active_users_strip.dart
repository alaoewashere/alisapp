import 'package:flutter/material.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/arabic_number.dart';
import '../../../shared/models/conversation_model.dart';
import 'chat_user_avatar.dart';

/// A user surfaced in the active-users strip at the top of the inbox.
class ActiveChatUser {
  const ActiveChatUser({
    required this.userId,
    required this.name,
    this.avatarSeed,
    this.isOnline = false,
    this.conversationId,
  });

  final String userId;
  final String name;
  final String? avatarSeed;
  final bool isOnline;
  final String? conversationId;
}

/// Derives unique recent chat partners for the horizontal active-users row.
List<ActiveChatUser> extractActiveChatUsers(
  List<ConversationModel> conversations,
  String currentUserId,
) {
  final seen = <String>{};
  final result = <ActiveChatUser>[];
  final now = DateTime.now();

  for (final conversation in conversations) {
    final otherId = conversation.otherUserId(currentUserId);
    if (seen.contains(otherId)) continue;
    seen.add(otherId);

    final lastTime = conversation.lastMessageTime ?? conversation.createdAt;
    final isOnline = now.difference(lastTime).inMinutes < 30;

    result.add(
      ActiveChatUser(
        userId: otherId,
        name: conversation.otherUserName ?? 'مستخدم',
        avatarSeed: conversation.otherUserAvatarSeed,
        isOnline: isOnline,
        conversationId: conversation.id,
      ),
    );
    if (result.length >= 8) break;
  }

  return result;
}

/// Count of conversations with activity in the last 24 hours.
int countRecentlyActiveConversations(List<ConversationModel> conversations) {
  final cutoff = DateTime.now().subtract(const Duration(hours: 24));
  return conversations.where((c) {
    final t = c.lastMessageTime ?? c.createdAt;
    return t.isAfter(cutoff);
  }).length;
}

/// Horizontal scrolling row of recently active chat partners.
class ActiveUsersStrip extends StatelessWidget {
  const ActiveUsersStrip({
    super.key,
    required this.users,
    required this.activeCount,
    this.onUserTap,
  });

  final List<ActiveChatUser> users;
  final int activeCount;
  final void Function(ActiveChatUser user)? onUserTap;

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الرسائل والمحادثات',
                      style: AppFonts.cairo(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'تواصل مباشرة مع المشترين والبائعين',
                      style: AppFonts.cairo(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (activeCount > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.badgeBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    '${arabicNumber(activeCount)} نشط',
                    style: AppFonts.cairo(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.badgeText,
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 78,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              return ActiveUserChip(
                name: user.name,
                avatarSeed: user.avatarSeed,
                online: user.isOnline,
                onTap: onUserTap != null ? () => onUserTap!(user) : null,
              );
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
