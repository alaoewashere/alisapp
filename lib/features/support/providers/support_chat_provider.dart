import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../data/support_chat_repository.dart';
import '../data/support_message_model.dart';

export '../data/support_chat_repository.dart';
export '../data/support_message_model.dart';

final supportMessagesStreamProvider =
    StreamProvider<List<SupportMessageModel>>((ref) {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return Stream.value([]);
  return ref.watch(supportChatRepositoryProvider).subscribeToMessages(userId);
});

final supportChatNotifierProvider =
    NotifierProvider<SupportChatNotifier, AsyncValue<void>>(
  SupportChatNotifier.new,
);

class SupportChatNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> sendMessage(String body) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(supportChatRepositoryProvider).sendMessage(
          userId: userId,
          body: body,
        );
  }

  Future<void> markAsRead() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(supportChatRepositoryProvider).markAsRead(userId);
  }
}
