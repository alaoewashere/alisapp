import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/utils/secure_log.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';
import '../../listings/data/listings_repository.dart';
import '../data/chat_repository.dart';

export '../data/chat_repository.dart';

const _uuid = Uuid();

final conversationsStreamProvider =
    StreamProvider<List<ConversationModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(chatRepositoryProvider).subscribeToConversations(userId);
});

final messagesStreamProvider =
    StreamProvider.family<List<MessageModel>, String>((ref, conversationId) {
  return ref.watch(chatRepositoryProvider).subscribeToMessages(conversationId);
});

final conversationProvider =
    FutureProvider.family<ConversationModel?, String>((ref, conversationId) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(chatRepositoryProvider).getConversationById(
        conversationId,
        userId,
      );
});

final unreadCountProvider = StreamProvider<int>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value(0);
  return ref.watch(chatRepositoryProvider).subscribeToUnreadCount(userId);
});

final chatNearBottomProvider =
    NotifierProvider.autoDispose<ChatNearBottomNotifier, bool>(
  ChatNearBottomNotifier.new,
);

class ChatNearBottomNotifier extends Notifier<bool> {
  @override
  bool build() => true;

  void setNearBottom(bool value) => state = value;
}

final pendingMessagesProvider = NotifierProvider.autoDispose
    .family<PendingMessagesNotifier, List<MessageModel>, String>(
  PendingMessagesNotifier.new,
);

class PendingMessagesNotifier extends Notifier<List<MessageModel>> {
  PendingMessagesNotifier(this.conversationId);

  final String conversationId;

  @override
  List<MessageModel> build() => [];

  void add(MessageModel message) => state = [...state, message];

  void remove(String id) =>
      state = state.where((m) => m.id != id).toList(growable: false);
}

final chatNotifierProvider = NotifierProvider<ChatNotifier, AsyncValue<void>>(
  ChatNotifier.new,
);

class ChatNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<ConversationModel> startChatFromListing({
    required String listingId,
    required String sellerId,
    required String listingTitle,
  }) async {
    final buyerId = ref.read(currentUserIdProvider);
    if (buyerId == null) throw StateError('Not authenticated');

    final result = await ref.read(chatRepositoryProvider).getOrCreateConversation(
          listingId: listingId,
          buyerId: buyerId,
          sellerId: sellerId,
          listingTitle: listingTitle,
        );

    // Navigation only needs the conversation id — sharing the listing card is
    // "nice to have on arrival", not something worth making the user wait 3-4
    // extra network round-trips for. Fire it in the background instead.
    unawaited(
      _shareListingCardIfNeeded(
        conversationId: result.conversation.id,
        listingId: listingId,
        listingTitle: listingTitle,
        buyerId: buyerId,
      ),
    );

    return result.conversation;
  }

  // One thread per person, but each listing they've messaged about gets its
  // own card the first time it comes up — so re-contacting about the SAME
  // listing doesn't spam a duplicate, and a NEW listing in an existing
  // thread still shows up clearly instead of being silently dropped.
  Future<void> _shareListingCardIfNeeded({
    required String conversationId,
    required String listingId,
    required String listingTitle,
    required String buyerId,
  }) async {
    try {
      final alreadyShared = await ref.read(chatRepositoryProvider).hasSharedListing(
            conversationId: conversationId,
            listingId: listingId,
          );
      if (alreadyShared) return;

      final locale = normalizeAppLocale(ref.read(localeProvider));
      final strings = lookupAppLocalizations(locale);
      final intro = strings.chatListingIntro(listingTitle);
      await ref.read(chatRepositoryProvider).sendListingCardMessage(
            conversationId: conversationId,
            senderId: buyerId,
            listingId: listingId,
            introText: intro,
          );
      await ref.read(listingsRepositoryProvider).incrementContacts(listingId);
      SecureLog.debug('chat: shared listing card for conversation $conversationId');
    } catch (e, stackTrace) {
      SecureLog.debug('chat: failed to share listing card: $e\n$stackTrace');
    }
  }

  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String sellerId,
    required String listingTitle,
  }) async {
    final buyerId = ref.read(currentUserIdProvider);
    if (buyerId == null) throw StateError('Not authenticated');

    final result = await ref.read(chatRepositoryProvider).getOrCreateConversation(
          listingId: listingId,
          buyerId: buyerId,
          sellerId: sellerId,
          listingTitle: listingTitle,
        );
    return result.conversation;
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final trimmed = content.trim();
    if (trimmed.isEmpty) return;

    final tempId = _uuid.v4();
    final optimistic = MessageModel(
      id: tempId,
      conversationId: conversationId,
      senderId: userId,
      content: trimmed,
      createdAt: DateTime.now(),
      isPending: true,
    );

    ref.read(pendingMessagesProvider(conversationId).notifier).add(optimistic);

    try {
      await ref.read(chatRepositoryProvider).sendMessage(
            conversationId: conversationId,
            senderId: userId,
            content: trimmed,
          );
      ref.read(pendingMessagesProvider(conversationId).notifier).remove(tempId);
    } catch (e, st) {
      ref.read(pendingMessagesProvider(conversationId).notifier).remove(tempId);
      state = AsyncError(e, st);
    }
  }

  Future<void> markAsRead(String conversationId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(chatRepositoryProvider).markMessagesAsRead(
          conversationId: conversationId,
          currentUserId: userId,
        );
    // Refresh the unread badge + conversation list so they clear right away.
    ref.invalidate(unreadCountProvider);
    ref.invalidate(conversationsStreamProvider);
  }

  Future<void> deleteConversation(String conversationId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(chatRepositoryProvider).deleteConversation(conversationId);
    });
  }
}
