import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_client.dart';

final blockedWordsRepositoryProvider = Provider<BlockedWordsRepository>((ref) {
  return BlockedWordsRepository(ref.watch(supabaseClientProvider));
});

class BlockedWordsRepository {
  BlockedWordsRepository(this._client);

  final SupabaseClient _client;

  Future<List<String>> fetchActiveNormalizedForms() async {
    final data = await _client
        .from('blocked_words')
        .select('normalized_form')
        .eq('active', true);

    return (data as List)
        .map((row) => (row['normalized_form'] as String?)?.trim() ?? '')
        .where((w) => w.isNotEmpty)
        .toList(growable: false);
  }
}
