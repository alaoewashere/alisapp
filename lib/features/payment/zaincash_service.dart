import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase/supabase_client.dart';
import '../../core/utils/result.dart';
import 'zaincash_config.dart';

/// A started ZainCash checkout: where to send the customer and how to track it.
class ZainCashCheckout {
  const ZainCashCheckout({required this.orderId, required this.payUrl});

  final String orderId;
  final String payUrl;
}

/// Final, server-verified outcome of an order, read from `zaincash_orders`.
class ZainCashOrderStatus {
  const ZainCashOrderStatus({required this.status, this.transactionId});

  /// One of `pending`, `paid`, `failed`, `cancelled`.
  final String status;
  final String? transactionId;

  bool get isPaid => status == 'paid';
}

/// Client for the ZainCash flow. Talks to the backend — it holds no secret and
/// never decides payment outcomes itself.
class ZainCashService {
  ZainCashService({SupabaseClient? client}) : _client = client ?? supabase;

  final SupabaseClient _client;

  /// Asks the backend to create a transaction. On success the caller opens
  /// [ZainCashCheckout.payUrl] in a WebView.
  Future<Result<ZainCashCheckout>> startCheckout({
    required int amount,
    String? listingId,
    String? serviceType,
  }) async {
    if (amount < 250) {
      return const Failure('المبلغ يجب أن يكون 250 دينار على الأقل');
    }

    try {
      final response = await _client.functions.invoke(
        ZainCashConfig.initFunction,
        body: {
          'amount': amount,
          'listing_id': ?listingId,
          'service_type': ?serviceType,
        },
      );

      final data = response.data;
      if (response.status != 200 || data is! Map) {
        final detail = data is Map ? (data['detail'] ?? data['error']) : data;
        return Failure('تعذّر بدء الدفع: ${detail ?? response.status}');
      }

      final orderId = data['order_id']?.toString();
      final payUrl = data['pay_url']?.toString();
      if (orderId == null || payUrl == null) {
        return const Failure('استجابة غير صالحة من الخادم');
      }
      return Success(ZainCashCheckout(orderId: orderId, payUrl: payUrl));
    } catch (e) {
      return Failure('تعذّر الاتصال بالخادم: $e', cause: e);
    }
  }

  /// Reads the authoritative status of an order from the database.
  Future<Result<ZainCashOrderStatus>> fetchOrderStatus(String orderId) async {
    try {
      final row = await _client
          .from(ZainCashConfig.ordersTable)
          .select('status, transaction_id')
          .eq('order_id', orderId)
          .maybeSingle();

      if (row == null) {
        return const Failure('لم يتم العثور على عملية الدفع');
      }
      return Success(
        ZainCashOrderStatus(
          status: row['status']?.toString() ?? 'pending',
          transactionId: row['transaction_id']?.toString(),
        ),
      );
    } catch (e) {
      return Failure('تعذّر قراءة حالة الدفع: $e', cause: e);
    }
  }
}
