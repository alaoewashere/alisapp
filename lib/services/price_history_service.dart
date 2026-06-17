import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/supabase/supabase_client.dart';
import '../models/price_history.dart';

final priceHistoryServiceProvider = Provider<PriceHistoryService>((ref) {
  return PriceHistoryService(ref.watch(supabaseClientProvider));
});

final priceHistoryProvider =
    FutureProvider.family<PriceHistoryData, String>((ref, listingId) {
  return ref.watch(priceHistoryServiceProvider).getHistory(listingId);
});

class PriceHistoryService {
  PriceHistoryService(this._client);

  final SupabaseClient _client;

  Future<PriceHistoryData> getHistory(String listingId) async {
    final listing = await _client
        .from('listings')
        .select('original_price, price_iqd, price, created_at')
        .eq('id', listingId)
        .maybeSingle();

    if (listing == null) {
      return PriceHistoryData(
        originalPrice: 0,
        listedAt: DateTime.now(),
        changes: const [],
        timeline: const [],
      );
    }

    final originalPrice =
        (listing['original_price'] as num?)?.toInt() ??
        (listing['price_iqd'] as num?)?.toInt() ??
        (listing['price'] as num?)?.toInt() ??
        0;
    final listedAt = DateTime.parse(listing['created_at'] as String);

    final rows = await _client
        .from('price_history')
        .select()
        .eq('listing_id', listingId)
        .order('changed_at', ascending: true);

    final changes = (rows as List)
        .map((row) => PriceHistoryEntry.fromJson(row as Map<String, dynamic>))
        .toList();

    final timeline = buildPriceHistoryTimeline(
      originalPrice: originalPrice,
      listedAt: listedAt,
      changes: changes,
    );

    return PriceHistoryData(
      originalPrice: originalPrice,
      listedAt: listedAt,
      changes: changes,
      timeline: timeline,
    );
  }
}
