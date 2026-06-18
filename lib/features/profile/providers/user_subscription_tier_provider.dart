import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/supabase_client.dart';
import '../utils/listing_boost_utils.dart';

final userSubscriptionTierProvider =
    FutureProvider.autoDispose<UserSubscriptionTier>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return UserSubscriptionTier.standard;

  final rows = await ref.watch(supabaseClientProvider).from('listing_purchases').select(
        'package_type',
      ).eq('user_id', userId);

  final types = (rows as List).map((r) => r['package_type'] as String?);
  return UserSubscriptionTier.fromPurchases(types);
});
