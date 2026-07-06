import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import 'support_message_model.dart';

final supportChatRepositoryProvider = Provider<SupportChatRepository>((ref) {
  return SupportChatRepository(ref.watch(supabaseClientProvider));
});

/// Simple user↔admin support thread — separate from the peer-to-peer listing
/// chat system (no listing_id, no second real auth account needed for "admin").
class SupportChatRepository {
  SupportChatRepository(this._client);

  final SupabaseClient _client;

  Future<List<SupportMessageModel>> getMessages(String userId) async {
    final data = await _client
        .from('support_messages')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);

    return (data as List)
        .map((e) => SupportMessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<SupportMessageModel> sendMessage({
    required String userId,
    required String body,
  }) async {
    final trimmed = body.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    final data = await _client.from('support_messages').insert({
      'user_id': userId,
      'sender_role': 'user',
      'body': trimmed,
    }).select().single();

    return SupportMessageModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> markAsRead(String userId) async {
    await _client
        .from('support_messages')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('sender_role', 'admin')
        .eq('is_read', false);
  }

  Stream<List<SupportMessageModel>> subscribeToMessages(String userId) {
    return _client
        .from('support_messages')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at')
        .map(
          (rows) => rows
              .map((e) => SupportMessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
  }
}
