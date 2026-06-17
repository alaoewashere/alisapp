import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/chat_date_utils.dart';
import '../../../core/utils/phone_links.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../widgets/user_avatar.dart';
import '../providers/chat_provider.dart';
import '../widgets/listing_context_card.dart';
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

class ChatScreen extends ConsumerWidget {
  const ChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserIdProvider);
    final conversationAsync = ref.watch(conversationProvider(conversationId));
    final messagesAsync = ref.watch(messagesStreamProvider(conversationId));
    final pending = ref.watch(pendingMessagesProvider(conversationId));

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
      backgroundColor: AppColors.chatBackground,
      resizeToAvoidBottomInset: true,
      appBar: conversationAsync.when(
        loading: () => _buildLoadingAppBar(context),
        error: (_, _) => _buildLoadingAppBar(context),
        data: (conversation) {
          if (conversation == null) {
            return _buildLoadingAppBar(context);
          }
          return _ChatAppBar(conversation: conversation);
        },
      ),
      body: Column(
        children: [
          _ChatOfflineBanner(),
          conversationAsync.maybeWhen(
            data: (conversation) {
              if (conversation == null) return const SizedBox.shrink();
              return ListingContextCard(conversation: conversation);
            },
            orElse: () => const SizedBox.shrink(),
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
                  return Center(
                    child: Text(
                      'ابدأ المحادثة',
                      style: AppFonts.tajawal(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  );
                }
                final otherSeed = conversationAsync.value?.otherUserAvatarSeed;
                return _MessagesList(
                  conversationId: conversationId,
                  messages: merged,
                  userId: userId,
                  otherUserAvatarSeed: otherSeed,
                );
              },
            ),
          ),
          _ChatInputBar(conversationId: conversationId),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildLoadingAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0.5,
      leadingWidth: 40,
      leading: AppBackButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
      title: Text(
        'محادثة',
        style: AppFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
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

class _ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _ChatAppBar({required this.conversation});

  final ConversationModel conversation;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool get _isOnline {
    final last = conversation.lastMessageTime ?? conversation.createdAt;
    return DateTime.now().difference(last).inMinutes < 30;
  }

  void _showChatOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.storefront_outlined),
              title: const Text('عرض الإعلان'),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/listing/${conversation.listingId}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: const Text('حظر المستخدم'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ميزة الحظر قريباً')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('الإبلاغ عن المحادثة'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم استلام بلاغك')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final name = c.otherUserName ?? 'مستخدم';

    return AppBar(
      backgroundColor: AppColors.canvas,
      elevation: 0.5,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: Colors.transparent,
      leadingWidth: 40,
      leading: AppBackButton(
        onPressed: () {
          if (context.canPop()) {
            context.pop();
          }
        },
      ),
      title: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(avatarSeed: c.otherUserAvatarSeed, size: 38),
              if (_isOnline)
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
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                if (_isOnline)
                  Text(
                    'متصل الآن',
                    style: AppFonts.tajawal(
                      fontSize: 11,
                      color: AppColors.approved,
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
            icon: const Icon(Icons.call_outlined, color: AppColors.textDark, size: 22),
            onPressed: () => launchPhoneCall(c.otherUserPhone),
          )
        else
          IconButton(
            icon: const Icon(Icons.call_outlined, color: AppColors.textDark, size: 22),
            onPressed: () {},
          ),
        IconButton(
          icon: const Icon(Icons.more_horiz, color: AppColors.textDark, size: 22),
          onPressed: () => _showChatOptions(context),
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
    this.otherUserAvatarSeed,
  });

  final String conversationId;
  final List<MessageModel> messages;
  final String? userId;
  final String? otherUserAvatarSeed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(_chatScrollControllerProvider(conversationId));

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final prev = index > 0 ? messages[index - 1] : null;
        final next = index < messages.length - 1 ? messages[index + 1] : null;

        final showDate = prev == null ||
            !isSameChatDay(prev.createdAt, message.createdAt);

        final isFirstInGroup = prev == null ||
            prev.senderId != message.senderId ||
            !isSameChatDay(prev.createdAt, message.createdAt);
        final isLastInGroup = next == null ||
            next.senderId != message.senderId ||
            !isSameChatDay(next.createdAt, message.createdAt);

        return KeyedSubtree(
          key: ValueKey(message.id),
          child: Column(
            children: [
              if (showDate) ChatDateSeparator(date: message.createdAt),
              if (userId != null)
                MessageBubble(
                  message: message,
                  currentUserId: userId!,
                  isFirstInGroup: isFirstInGroup,
                  isLastInGroup: isLastInGroup,
                  otherUserAvatarSeed: otherUserAvatarSeed,
                ),
            ],
          ),
        );
      },
    );
  }
}

class _ChatInputBar extends ConsumerStatefulWidget {
  const _ChatInputBar({required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<_ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends ConsumerState<_ChatInputBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!mounted) return;
    final text = _controller.text;
    if (text.trim().isEmpty) return;
    _controller.clear();
    await ref.read(chatNotifierProvider.notifier).sendMessage(
          conversationId: widget.conversationId,
          content: text,
        );
    if (!mounted) return;
    ref.read(chatNearBottomProvider.notifier).setNearBottom(true);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)
          .add(EdgeInsets.only(bottom: bottomInset > 0 ? 0 : 8)),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final hasText = value.text.trim().isNotEmpty;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasText)
                  GestureDetector(
                    onTap: _send,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.send_rounded,
                        color: AppColors.canvas,
                        size: 18,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: TextField(
                        controller: _controller,
                        style: AppFonts.tajawal(
                          fontSize: 14,
                          color: AppColors.pureWhite,
                        ),
                        decoration: InputDecoration(
                          hintText: 'اكتب رسالة...',
                          hintStyle: AppFonts.tajawal(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        minLines: 1,
                        maxLines: 5,
                        textDirection: TextDirection.rtl,
                        onSubmitted: hasText ? (_) => _send() : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!hasText)
                  IconButton(
                    icon: const Icon(
                      Icons.mic_none_rounded,
                      color: AppColors.textMuted,
                      size: 24,
                    ),
                    onPressed: () {},
                  ),
                IconButton(
                  icon: const Icon(
                    Icons.sentiment_satisfied_outlined,
                    color: AppColors.textMuted,
                    size: 24,
                  ),
                  onPressed: () {},
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
      children: const [
        ShimmerBox(height: 48, width: 220),
        SizedBox(height: 8),
        ShimmerBox(height: 48, width: 180),
        SizedBox(height: 8),
        ShimmerBox(height: 48, width: 240),
      ],
    );
  }
}

class _ChatOfflineBanner extends ConsumerWidget {
  const _ChatOfflineBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkAsync = ref.watch(_networkStatusProvider);
    final offline =
        networkAsync.value?.contains(ConnectivityResult.none) ?? false;
    if (!offline) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: AppColors.surfaceMuted,
      child: Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'جاري إعادة الاتصال...',
            style: AppFonts.cairo(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
