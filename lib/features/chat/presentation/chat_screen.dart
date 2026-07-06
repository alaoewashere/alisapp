import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/utils/chat_date_utils.dart';
import '../../../core/utils/phone_links.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/shimmer_loading.dart';
import '../../../widgets/user_avatar.dart';
import '../../../core/moderation/moderation_provider.dart';
import '../providers/chat_provider.dart';
import '../widgets/listing_context_card.dart';
import '../widgets/message_bubble.dart';

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
    final strings = ref.watch(appLocalizationsProvider);

    ref.listen(messagesStreamProvider(conversationId), (prev, next) {
      final prevLen = prev?.value?.length ?? 0;
      final nextLen = next.value?.length ?? 0;
      if (nextLen > prevLen && ref.read(chatNearBottomProvider)) {
        _scrollToBottom(ref);
      }
      // Mark read both when a new message arrives AND when the chat first opens
      // (so unread badges clear on open, not only on the next message).
      final justOpened = (prev?.value == null) && next.hasValue;
      if (nextLen > prevLen || justOpened) {
        ref.read(chatNotifierProvider.notifier).markAsRead(conversationId);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      resizeToAvoidBottomInset: true,
      appBar: conversationAsync.when(
        loading: () => _buildLoadingAppBar(context, strings),
        error: (_, _) => _buildLoadingAppBar(context, strings),
        data: (conversation) {
          if (conversation == null) {
            return _buildLoadingAppBar(context, strings);
          }
          return _ChatAppBar(conversation: conversation, strings: strings);
        },
      ),
      body: Column(
        children: [
          const _SafeMeetupBanner(),
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
                      strings.startConversation,
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
          _ChatInputBar(conversationId: conversationId, strings: strings),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildLoadingAppBar(
    BuildContext context,
    AppLocalizations strings,
  ) {
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
        strings.conversation,
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
  const _ChatAppBar({
    required this.conversation,
    required this.strings,
  });

  final ConversationModel conversation;
  final AppLocalizations strings;

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
              title: Text(strings.viewListing),
              onTap: () {
                Navigator.pop(ctx);
                context.push('/listing/${conversation.listingId}');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_outlined),
              title: Text(strings.blockUser),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.blockFeatureComingSoon)),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(strings.reportConversation),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(strings.reportReceived)),
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
    final name = c.otherUserName ?? strings.defaultUser;

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
                    strings.onlineNow,
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
              if (message.isListingCard && message.listingTitle != null)
                ListingContextCard(
                  listingId: message.listingId!,
                  title: message.listingTitle!,
                  imageUrl: message.listingImage,
                  price: message.listingPrice,
                ),
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
  const _ChatInputBar({
    required this.conversationId,
    required this.strings,
  });

  final String conversationId;
  final AppLocalizations strings;

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

    if (await checkPostingBanGate(ref, context)) return;

    final moderation = await moderateUserText(ref, text: text);
    if (!mounted) return;

    if (moderation.shouldBlock) {
      PostingBanInfo? banInfo;
      try {
        banInfo = await recordClientModerationBlock(
          ref.read(moderationRepositoryProvider),
          source: 'chat',
          fieldName: 'body',
          excerpt: text,
        );
        ref.invalidateModerationState();
      } catch (e) {
        if (!mounted) return;
        await handlePostingBanOrBlockError(ref, context, e);
        return;
      }
      if (!mounted) return;
      await showModerationBlockedWarning(context, banInfo: banInfo);
      return;
    }

    if (moderation.hadViolation) {
      await showModerationCensoredWarning(context);
    }

    _controller.clear();
    try {
      // Send original text — server trigger detects, logs, and censors on insert.
      await ref.read(chatNotifierProvider.notifier).sendMessage(
            conversationId: widget.conversationId,
            content: text.trim(),
          );
    } catch (e) {
      if (!mounted) return;
      await handlePostingBanOrBlockError(ref, context, e);
      return;
    }
    if (!mounted) return;
    ref.invalidateModerationState();
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
                // Send — always present; volt + glow when there's text to send.
                GestureDetector(
                  onTap: hasText ? _send : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: hasText ? AppColors.volt : AppColors.surfaceMuted,
                      shape: BoxShape.circle,
                      boxShadow: hasText
                          ? const [
                              BoxShadow(
                                color: Color(0x4DD4FF3A),
                                blurRadius: 12,
                                offset: Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.send_rounded,
                      color: hasText ? AppColors.canvas : AppColors.textMuted,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 120),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 11,
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
                          hintText: widget.strings.typeMessage,
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
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Subtle persistent reminder to meet safely — builds buyer/seller trust.
class _SafeMeetupBanner extends StatelessWidget {
  const _SafeMeetupBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      color: AppColors.volt.withValues(alpha: 0.06),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 15, color: AppColors.volt),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'للأمان: قابل الطرف الآخر بمكان عام، وافحص الغرض قبل الدفع.',
              style: AppFonts.cairo(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
                height: 1.4,
              ),
            ),
          ),
        ],
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

