import 'package:supabase_flutter/supabase_flutter.dart';

/// Columns safe to expose for seller/public profile cards.
const publicProfileSelect =
    'id, full_name, display_name, username, avatar_url, avatar_seed, avatar_index, '
    'phone, city, governorate, is_verified, verification_status, '
    'verification_submitted_at, verification_reviewed_at, rejection_reason, '
    'avg_rating, rating_count, is_suspended, created_at, updated_at';

/// Reads public seller profiles; falls back to `profiles` when the view is missing.
Future<List<Map<String, dynamic>>> fetchPublicProfiles(
  SupabaseClient client,
  List<String> userIds,
) async {
  if (userIds.isEmpty) return [];

  try {
    final rows = await client
        .from('public_profiles')
        .select(publicProfileSelect)
        .inFilter('id', userIds);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  } on PostgrestException catch (e) {
    final missingView = e.code == 'PGRST205' ||
        e.message.contains('public_profiles') ||
        e.message.contains('schema cache');
    if (!missingView) rethrow;

    final rows = await client
        .from('profiles')
        .select(publicProfileSelect)
        .inFilter('id', userIds)
        .eq('is_deleted', false);
    return (rows as List)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }
}
