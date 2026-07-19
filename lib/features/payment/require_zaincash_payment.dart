import 'package:flutter/material.dart';

import '../../core/utils/result.dart';
import 'zaincash_checkout_screen.dart';
import 'zaincash_service.dart';

/// Starts a ZainCash checkout for [amountIqd] and pushes the hosted payment
/// WebView, blocking until the user completes, cancels, or the payment fails.
///
/// Returns the ZainCash order id (to pass through as `payment_reference` so
/// the backend can verify it) only if the order actually settled as paid.
/// Returns `null` on any other outcome — cancelled, failed, or unable to even
/// start the checkout — after showing an explanatory snackbar, so callers can
/// simply bail out of whatever paid action they were about to take.
Future<String?> requireZainCashPayment(
  BuildContext context, {
  required int amountIqd,
  String? listingId,
  String? serviceType,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);
  final service = ZainCashService();

  final init = await service.startCheckout(
    amount: amountIqd,
    listingId: listingId,
    serviceType: serviceType,
  );

  switch (init) {
    case Failure(:final message):
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return null;
    case Success(:final value):
      if (!context.mounted) return null;
      final status = await navigator.push<ZainCashOrderStatus>(
        MaterialPageRoute(
          builder: (_) => ZainCashCheckoutScreen(
            checkout: value,
            service: service,
          ),
        ),
      );

      if (status == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('تم إلغاء عملية الدفع')),
        );
        return null;
      }
      if (!status.isPaid) {
        messenger.showSnackBar(
          const SnackBar(content: Text('تعذّر إتمام الدفع، حاول مرة أخرى')),
        );
        return null;
      }
      return value.orderId;
  }
}
