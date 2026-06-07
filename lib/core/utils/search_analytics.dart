import '../supabase/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Fire-and-forget search log insert.
void logSearch({
  required SupabaseClient client,
  String? userId,
  required String query,
  required int resultsCount,
}) {
  () async {
    try {
      await client.from('search_logs').insert({
        'user_id': ?userId,
        'query': query.trim(),
        'results_count': resultsCount,
      });
    } catch (_) {}
  }();
}
