import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/chat_provider.dart';
import '../widgets/conversation_tile.dart';

class ConversationsScreen extends ConsumerWidget {
  const ConversationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final unreadAsync = ref.watch(unreadCountProvider);
    final unread = unreadAsync.value ?? 0;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('رسائلي')),
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
      appBar: AppBar(
        title: Row(
          children: [
            const Text('رسائلي'),
            if (unread > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  unread > 99 ? '99+' : '$unread',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
      body: conversationsAsync.when(
        loading: () => const LoadingWidget(message: 'جاري التحميل...'),
        error: (e, _) => AppErrorWidget(
          message: '$e',
          onRetry: () => ref.invalidate(conversationsStreamProvider),
        ),
        data: (conversations) {
          if (conversations.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 80,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد رسائل بعد',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'ابدأ بالتواصل مع البائعين',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            itemCount: conversations.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return ConversationTile(
                conversation: conversation,
                onTap: () => context.push('/chat/${conversation.id}'),
                onLongPress: () => _showDeleteDialog(context, ref, conversation.id),
              );
            },
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
