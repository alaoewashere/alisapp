import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/public_profiles_query.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/conversation_model.dart';
import '../../../shared/models/message_model.dart';

/// Result of opening or creating a listing-scoped conversation.
class ConversationCreateResult {
  const ConversationCreateResult({
    required this.conversation,
    required this.isNew,
  });

  final ConversationModel conversation;
  final bool isNew;
}

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
    )
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
    await _attachParticipantProfiles(row);
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

  Future<void> _attachParticipantProfiles(Map<String, dynamic> row) async {
    final buyerId = row['buyer_id'] as String?;
    final sellerId = row['seller_id'] as String?;
    final ids = [buyerId, sellerId].whereType<String>().toList();
    if (ids.isEmpty) return;

    final profiles = await fetchPublicProfiles(_client, ids);
    for (final map in profiles) {
      final id = map['id'] as String;
      if (id == buyerId) row['buyer'] = map;
      if (id == sellerId) row['seller'] = map;
    }
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

  Future<ConversationCreateResult> getOrCreateConversation({
    required String listingId,
    required String buyerId,
    required String sellerId,
    required String listingTitle,
  }) async {
    if (buyerId == sellerId) {
      throw ArgumentError('Cannot chat with yourself');
    }

    // One thread per PERSON (not per listing): reuse any existing conversation
    // between these two users, whichever direction the buyer/seller roles are.
    final existing = await _client
        .from('conversations')
        .select(_conversationSelect)
        .or(
          'and(buyer_id.eq.$buyerId,seller_id.eq.$sellerId),'
          'and(buyer_id.eq.$sellerId,seller_id.eq.$buyerId)',
        )
        .order('last_message_at', ascending: false)
        .limit(1)
        .maybeSingle();

    if (existing != null) {
      return ConversationCreateResult(
        conversation: await _mapConversationRow(
          Map<String, dynamic>.from(existing),
          buyerId,
        ),
        isNew: false,
      );
    }

    final inserted = await _client.from('conversations').insert({
      'listing_id': listingId,
      'buyer_id': buyerId,
      'seller_id': sellerId,
    }).select(_conversationSelect).single();

    return ConversationCreateResult(
      conversation: await _mapConversationRow(
        Map<String, dynamic>.from(inserted),
        buyerId,
      ),
      isNew: true,
    );
  }

  /// Distinct buyers (with public profile) who messaged about [listingId] — for
  /// the "who did you sell to?" picker. Ordered by most-recent conversation.
  Future<List<Map<String, dynamic>>> getListingBuyers({
    required String listingId,
    required String sellerId,
  }) async {
    final data = await _client
        .from('conversations')
        .select('buyer_id, last_message_at')
        .eq('listing_id', listingId)
        .eq('seller_id', sellerId)
        .order('last_message_at', ascending: false);

    final seen = <String>{};
    final ids = <String>[];
    for (final row in data as List) {
      final id = (row as Map)['buyer_id'] as String?;
      if (id != null && seen.add(id)) ids.add(id);
    }
    if (ids.isEmpty) return const [];

    final profiles = await fetchPublicProfiles(_client, ids);
    final byId = {for (final p in profiles) p['id'] as String: p};
    return [for (final id in ids) if (byId[id] != null) byId[id]!];
  }

  // Listing snapshots don't change once shared into a chat — cache per id.
  final Map<String, Map<String, dynamic>?> _listingSnapshotCache = {};

  Future<Map<String, dynamic>?> _listingSnapshot(String listingId) async {
    if (_listingSnapshotCache.containsKey(listingId)) {
      return _listingSnapshotCache[listingId];
    }
    final data = await _client
        .from('listings')
        .select(
          'title_ar, title, price_iqd, price, listing_images(storage_path, url, sort_order, is_primary)',
        )
        .eq('id', listingId)
        .maybeSingle();
    if (data == null) {
      _listingSnapshotCache[listingId] = null;
      return null;
    }
    final map = Map<String, dynamic>.from(data);
    final snapshot = {
      'listing_title': map['title_ar'] as String? ?? map['title'] as String?,
      'listing_image': _listingImageFromRow(map),
      'listing_price': (map['price_iqd'] as num?)?.toDouble() ??
          (map['price'] as num?)?.toDouble(),
    };
    _listingSnapshotCache[listingId] = snapshot;
    return snapshot;
  }

  Future<List<MessageModel>> _mapMessages(List<dynamic> rows) async {
    final result = <MessageModel>[];
    for (final row in rows) {
      final map = Map<String, dynamic>.from(row as Map);
      final listingId = map['listing_id'] as String?;
      if (listingId != null) {
        final snapshot = await _listingSnapshot(listingId);
        if (snapshot != null) map.addAll(snapshot);
      }
      result.add(MessageModel.fromJson(map));
    }
    return result;
  }

  Future<List<MessageModel>> getMessages(String conversationId) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);

    return _mapMessages(data as List);
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

  /// Whether this listing was already shared as a card in this conversation —
  /// used to avoid spamming a duplicate card every time "Message Seller" is
  /// tapped again for a listing already introduced in this thread.
  Future<bool> hasSharedListing({
    required String conversationId,
    required String listingId,
  }) async {
    final data = await _client
        .from('messages')
        .select('id')
        .eq('conversation_id', conversationId)
        .eq('listing_id', listingId)
        .limit(1);
    return (data as List).isNotEmpty;
  }

  /// Shares a listing into the chat as its own message — appears inline in
  /// the timeline (not a single frozen banner), so a buyer can message the
  /// same seller about several listings in one thread and each stays clear.
  Future<MessageModel> sendListingCardMessage({
    required String conversationId,
    required String senderId,
    required String listingId,
    required String introText,
  }) async {
    final data = await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': senderId,
      'body': introText,
      'content': introText,
      'listing_id': listingId,
    }).select().single();

    await _client.from('conversations').update({
      'last_message': introText,
      'last_message_at': DateTime.now().toIso8601String(),
    }).eq('id', conversationId);

    final map = Map<String, dynamic>.from(data);
    final snapshot = await _listingSnapshot(listingId);
    if (snapshot != null) map.addAll(snapshot);
    return MessageModel.fromJson(map);
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
        .asyncMap(_mapMessages);
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
