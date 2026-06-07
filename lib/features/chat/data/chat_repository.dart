import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(ref.watch(supabaseClientProvider));
});

class ChatRepository {
  ChatRepository(this._client);

  final SupabaseClient _client;

  static const _conversationSelect = '''
    *,
    listings(
      title, title_ar, price_iqd, price,
      listing_images(storage_path, url, sort_order, is_primary)
    ),
    buyer:profiles!conversations_buyer_id_fkey(full_name, display_name, avatar_url, phone),
    seller:profiles!conversations_seller_id_fkey(full_name, display_name, avatar_url, phone)
  ''';

  String _publicUrl(String path) {
    if (path.startsWith('http')) return path;
    return _client.storage.from(AppConstants.storageBucket).getPublicUrl(path);
  }

  String? _listingImageFromRow(Map<String, dynamic>? listing) {
    if (listing == null) return null;
    final images = listing['listing_images'] as List<dynamic>?;
    if (images == null || images.isEmpty) return null;
    final sorted = [...images.map((e) => Map<String, dynamic>.from(e as Map))];
    sorted.sort((a, b) {
      final aPrimary = a['is_primary'] == true;
      final bPrimary = b['is_primary'] == true;
      if (aPrimary != bPrimary) return aPrimary ? -1 : 1;
      return ((a['sort_order'] as int?) ?? 0)
          .compareTo((b['sort_order'] as int?) ?? 0);
    });
    final first = sorted.first;
    final url = first['url'] as String? ?? first['storage_path'] as String?;
    if (url == null) return null;
    return _publicUrl(url);
  }

  Future<ConversationModel> _mapConversationRow(
    Map<String, dynamic> row,
    String currentUserId,
  ) async {
    final unread = await _unreadCountForConversation(
      row['id'] as String,
      currentUserId,
    );
    return ConversationModel.fromJson(
      row,
      currentUserId: currentUserId,
      unreadCount: unread,
      listingImageUrl: _listingImageFromRow(
        row['listings'] as Map<String, dynamic>?,
      ),
    );
  }

  Future<int> _unreadCountForConversation(
    String conversationId,
    String currentUserId,
  ) async {
    final data = await _client
        .from('messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .eq('is_read', false)
        .neq('sender_id', currentUserId);
    return (data as List).length;
  }

  Future<List<ConversationModel>> getConversations(String userId) async {
    final data = await _client
        .from('conversations')
        .select(_conversationSelect)
        .or('buyer_id.eq.$userId,seller_id.eq.$userId')
        .order('last_message_at', ascending: false);

    final conversations = <ConversationModel>[];
    for (final row in data as List) {
      conversations.add(
        await _mapConversationRow(
          Map<String, dynamic>.from(row as Map),
          userId,
        ),
      );
    }
    return conversations;
  }

  Future<ConversationModel?> getConversationById(
    String conversationId,
    String userId,
  ) async {
    final data = await _client
        .from('conversations')
        .select(_conversationSelect)
        .eq('id', conversationId)
        .maybeSingle();
    if (data == null) return null;
    return _mapConversationRow(
      Map<String, dynamic>.from(data),
      userId,
    );
  }

  Future<ConversationModel> getOrCreateConversation({
    required String listingId,
    required String buyerId,
    required String sellerId,
    required String listingTitle,
  }) async {
    if (buyerId == sellerId) {
      throw ArgumentError('Cannot chat with yourself');
    }

    final existing = await _client
        .from('conversations')
        .select(_conversationSelect)
        .eq('listing_id', listingId)
        .eq('buyer_id', buyerId)
        .eq('seller_id', sellerId)
        .maybeSingle();

    if (existing != null) {
      return _mapConversationRow(
        Map<String, dynamic>.from(existing),
        buyerId,
      );
    }

    final inserted = await _client.from('conversations').insert({
      'listing_id': listingId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
    }).select(_conversationSelect).single();

    return _mapConversationRow(
      Map<String, dynamic>.from(inserted),
      buyerId,
    );
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return (data as List)
        .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<MessageModel> sendMessage({
    required String conversationId,
    required String senderId,
    required String content,
  }) async {
    final trimmed = content.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Message cannot be empty');
    }

    final data = await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'body': trimmed,
      'content': trimmed,
    }).select().single();

    await _client.from('conversations').update({
      'last_message': trimmed,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);

    return MessageModel.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> markMessagesAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('conversation_id', conversationId)
        .neq('sender_id', currentUserId)
        .eq('is_read', false);
  }

  Stream<List<MessageModel>> subscribeToMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at')
        .map(
          (rows) => rows
              .map((e) => MessageModel.fromJson(Map<String, dynamic>.from(e)))
              .toList(),
        );
  }

  Stream<List<ConversationModel>> subscribeToConversations(String userId) {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .asyncMap((rows) async {
          final mine = rows.where((row) {
            final map = Map<String, dynamic>.from(row);
            return map['buyer_id'] == userId || map['seller_id'] == userId;
          }).toList();

          final enriched = <ConversationModel>[];
          for (final row in mine) {
            final id = row['id'] as String;
            final full = await _client
                .from('conversations')
                .select(_conversationSelect)
                .eq('id', id)
                .maybeSingle();
            if (full != null) {
              enriched.add(
                await _mapConversationRow(
                  Map<String, dynamic>.from(full),
                  userId,
                ),
              );
            }
          }
          enriched.sort((a, b) {
            final at = a.lastMessageTime ?? a.createdAt;
            final bt = b.lastMessageTime ?? b.createdAt;
            return bt.compareTo(at);
          });
          return enriched;
        });
  }

  Future<int> getTotalUnreadCount(String userId) async {
    final convs = await _client
        .from('conversations')
        .select('id')
        .or('buyer_id.eq.$userId,seller_id.eq.$userId');

    final ids = (convs as List).map((c) => c['id'] as String).toList();
    if (ids.isEmpty) return 0;

    var total = 0;
    for (final id in ids) {
      total += await _unreadCountForConversation(id, userId);
    }
    return total;
  }

  Stream<int> subscribeToUnreadCount(String userId) async* {
    yield await getTotalUnreadCount(userId);
    await for (final _ in _client.from('messages').stream(primaryKey: ['id'])) {
      yield await getTotalUnreadCount(userId);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    await _client.from('conversations').delete().eq('id', conversationId);
  }

  Future<void> saveOneSignalPlayerId(String userId, String playerId) async {
    await _client
        .from('profiles')
        .update({'onesignal_player_id': playerId}).eq('id', userId);
  }
}
