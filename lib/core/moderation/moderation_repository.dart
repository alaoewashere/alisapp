import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../supabase/supabase_client.dart';
import 'posting_ban_utils.dart';

final moderationRepositoryProvider = Provider<ModerationRepository>((ref) {
  return ModerationRepository(ref.watch(supabaseClientProvider));
});

class ModerationRepository {
  ModerationRepository(this._client);

  final SupabaseClient _client;

  Future<PostingBanInfo> recordModerationBlock({
    required String source,
    String? fieldName,
    String? excerpt,
  }) async {
    final data = await _client.rpc(
      'record_moderation_block',
      params: {
        'p_source': source,
        'p_field_name': fieldName,
        'p_excerpt': excerpt,
      },
    );
    return PostingBanInfo.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<PostingBanInfo?> fetchMyPostingBanStatus() async {
    final data = await _client.rpc('get_my_posting_ban_status');
    final map = Map<String, dynamic>.from(data as Map);
    if (map['is_banned'] != true) return null;
    return PostingBanInfo.fromJson(map);
  }
}
