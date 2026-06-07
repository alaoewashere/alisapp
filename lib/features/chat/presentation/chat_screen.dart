import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/models/conversation_model.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/chat_date_utils.dart';
import '../../../core/utils/phone_links.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/message_model.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';

final _networkStatusProvider = StreamProvider<List<ConnectivityResult>>((ref) {
  return Connectivity().onConnectivityChanged;
});

final _chatScrollControllerProvider =
    Provider.autoDispose.family<ScrollController, String>((ref, conversationId) {
  final controller = ScrollController();
  void listener() {
    if (!controller.hasClients) return;
    final nearBottom =
        controller.position.pixels >= controller.position.maxScrollExtent - 96;
    ref.read(chatNearBottomProvider.notifier).setNearBottom(nearBottom);
  }

  controller.addListener(listener);
  ref.onDispose(() {
    controller.removeListener(listener);
    controller.dispose();
  });
  return controller;
});

final _markedReadProvider = Provider.autoDispose.family<void, String>((ref, id) {
  Future.microtask(
    () => ref.read(chatNotifierProvider.notifier).markAsRead(id),
  );
});

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(_markedReadProvider(conversationId));

    final userId = ref.watch(currentUserIdProvider);
    final conversationAsync = ref.watch(conversationProvider(conversationId));
    final messagesAsync = ref.watch(messagesStreamProvider(conversationId));
    final pending = ref.watch(pendingMessagesProvider(conversationId));
    final networkAsync = ref.watch(_networkStatusProvider);
    final offline = networkAsync.value?.contains(ConnectivityResult.none) ?? false;

    ref.listen(messagesStreamProvider(conversationId), (prev, next) {
      final prevLen = prev?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen && ref.read(chatNearBottomProvider)) {
        _scrollToBottom(ref);
      }
      if (nextLen > prevLen) {
        ref.read(chatNotifierProvider.notifier).markAsRead(conversationId);
      }
    });

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: conversationAsync.when(
        loading: () => AppBar(title: const Text('محادثة')),
        error: (_, _) => AppBar(title: const Text('محادثة')),
        data: (conversation) {
          if (conversation == null) {
            return AppBar(title: const Text('محادثة'));
          }
          return _ChatAppBar(conversation: conversation);
        },
      ),
      body: Column(
        children: [
          if (offline)
            MaterialBanner(
              content: const Text('جاري إعادة الاتصال...'),
              leading: const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              actions: const [SizedBox.shrink()],
            ),
          Expanded(
            child: messagesAsync.when(
              loading: () => const _MessagesShimmer(),
              error: (e, _) => AppErrorWidget(
                message: '$e',
                onRetry: () =>
                    ref.invalidate(messagesStreamProvider(conversationId)),
              ),
              data: (streamMessages) {
                final merged = _mergeMessages(streamMessages, pending);
                if (merged.isEmpty) {
                  return const Center(
                    child: Text('ابدأ المحادثة'),
                  );
                }
                return _MessagesList(
                  conversationId: conversationId,
                  messages: merged,
                  userId: userId,
                );
              },
            ),
          ),
          _ChatInputBar(conversationId: conversationId),
        ],
      ),
    );
  }

  List<MessageModel> _mergeMessages(
    List<MessageModel> streamMessages,
    List<MessageModel> pending,
  ) {
    final ids = streamMessages.map((m) => m.id).toSet();
    final extra = pending.where((p) => !ids.contains(p.id)).toList();
    return [...streamMessages, ...extra]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  void _scrollToBottom(WidgetRef ref) {
    final controller = ref.read(_chatScrollControllerProvider(conversationId));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.conversation});

  final ConversationModel conversation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 52);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = conversation;
    final theme = Theme.of(context);

    return AppBar(
      titleSpacing: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: c.otherUserAvatar != null
                    ? CachedNetworkImageProvider(c.otherUserAvatar!)
                    : null,
                child: c.otherUserAvatar == null
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  c.otherUserName ?? 'مستخدم',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: () => context.push('/listing/${c.listingId}'),
            child: Row(
              children: [
                ChatListingThumb(url: c.listingImage, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    c.listingTitle ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                if (c.listingPrice != null)
                  Text(
                    formatIQD(c.listingPrice!),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (c.otherUserPhone != null && c.otherUserPhone!.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.phone_outlined),
            onPressed: () => launchPhoneCall(c.otherUserPhone),
          ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'listing':
                context.push('/listing/${c.listingId}');
              case 'block':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ميزة الحظر قريباً')),
                );
              case 'report':
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم استلام بلاغك')),
                );
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'listing', child: Text('عرض الإعلان')),
            PopupMenuItem(value: 'block', child: Text('حظر المستخدم')),
            PopupMenuItem(value: 'report', child: Text('الإبلاغ عن المحادثة')),
          ],
        ),
      ],
    );
  }
}

class _MessagesList extends ConsumerWidget {
  const _MessagesList({
    required this.conversationId,
    required this.messages,
    required this.userId,
  });

  final String conversationId;
  final List<MessageModel> messages;
  final String? userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_chatScrollControllerProvider(conversationId));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(chatNearBottomProvider) && controller.hasClients) {
        controller.jumpTo(controller.position.maxScrollExtent);
      }
    });

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final prev = index > 0 ? messages[index - 1] : null;
        final next = index < messages.length - 1 ? messages[index + 1] : null;

        final showDate = prev == null ||
            !isSameChatDay(prev.createdAt, message.createdAt);

        final isFirstInGroup =
            prev == null || prev.senderId != message.senderId ||
                !isSameChatDay(prev.createdAt, message.createdAt);
        final isLastInGroup =
            next == null || next.senderId != message.senderId ||
                !isSameChatDay(next.createdAt, message.createdAt);

        return Column(
          children: [
            if (showDate) ChatDateSeparator(date: message.createdAt),
            if (userId != null)
              MessageBubble(
                message: message,
                currentUserId: userId!,
                isFirstInGroup: isFirstInGroup,
                isLastInGroup: isLastInGroup,
              ),
          ],
        );
      },
    );
  }
}

class _ChatInputBar extends ConsumerWidget {
  const _ChatInputBar({required this.conversationId});

  final String conversationId;

  Future<void> _send(WidgetRef ref) async {
    final controller = ref.read(chatInputControllerProvider(conversationId));
    final text = controller.text;
    controller.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(
          conversationId: conversationId,
          content: text,
        );
    ref.read(chatNearBottomProvider.notifier).setNearBottom(true);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(chatInputControllerProvider(conversationId));
    final theme = Theme.of(context);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.emoji_emotions_outlined,
                    color: theme.colorScheme.outline,
                  ),
                ),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: TextField(
                      controller: controller,
                      textDirection: TextDirection.rtl,
                      maxLines: 5,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'اكتب رسالة...',
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: hasText ? (_) => _send(ref) : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: hasText
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    onTap: hasText ? () => _send(ref) : null,
                    borderRadius: BorderRadius.circular(24),
                    child: const SizedBox(
                      width: 48,
                      height: 48,
                      child: Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MessagesShimmer extends StatelessWidget {
  const _MessagesShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ShimmerBox(height: 48, width: 220),
        SizedBox(height: 8),
        ShimmerBox(height: 48, width: 180),
        SizedBox(height: 8),
        ShimmerBox(height: 48, width: 240),
      ],
    );
  }
}
