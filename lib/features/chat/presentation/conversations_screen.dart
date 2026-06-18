import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/chat_provider.dart';
import '../widgets/active_users_strip.dart';
import '../widgets/conversation_tile.dart';
import '../../../shared/widgets/app_bottom_nav.dart';
import '../../../shared/widgets/sello_app_bar.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);

    if (userId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: SelloAppBar(
          backgroundColor: AppColors.background,
          automaticallyImplyLeading: false,
          title: const Text('رسائلي'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('سجّل الدخول لعرض الرسائل'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push(AppRoutes.phone),
                child: const Text('تسجيل الدخول'),
              ),
            ],
          ),
        ),
      );
    }

    final conversationsAsync = ref.watch(conversationsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SelloAppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        automaticallyImplyLeading: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('رسائلي'),
      ),
      body: conversationsAsync.when(
        loading: () => const LoadingWidget(message: 'جاري التحميل...'),
        error: (e, _) => AppErrorWidget(
          message: '$e',
          onRetry: () => ref.invalidate(conversationsStreamProvider),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return const _EmptyInbox();
          }

          final activeUsers = extractActiveChatUsers(conversations, userId);
          final activeCount = countRecentlyActiveConversations(conversations);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ActiveUsersStrip(
                users: activeUsers,
                activeCount: activeCount,
                onUserTap: (user) {
                  if (user.conversationId != null) {
                    context.push('/chat/${user.conversationId}');
                  }
                },
              ),
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    0,
                    16,
                    AppBottomNavLayout.scrollBottomPadding(context),
                  ),
                  itemCount: conversations.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final conversation = conversations[index];
                    return ConversationTile(
                      conversation: conversation,
                      onTap: () => context.push('/chat/${conversation.id}'),
                      onLongPress: () =>
                          _showDeleteDialog(context, ref, conversation.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String conversationId,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('حذف المحادثة'),
        content: const Text('هل تريد حذف هذه المحادثة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(chatNotifierProvider.notifier).deleteConversation(conversationId);
    }
  }
}

class _EmptyInbox extends StatelessWidget {
  const _EmptyInbox();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: AppColors.textMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد رسائل بعد',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textDark,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'ابدأ بالتواصل مع البائعين',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textMuted,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
