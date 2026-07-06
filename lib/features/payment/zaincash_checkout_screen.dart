import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/utils/result.dart';
import 'zaincash_config.dart';
import 'zaincash_service.dart';

/// Opens the ZainCash hosted payment page in a WebView and, once the gateway
/// redirects back through our backend callback to [ZainCashConfig.returnUrlPrefix],
/// re-reads the authoritative order status from the database and pops it.
///
/// Returns the final [ZainCashOrderStatus], or `null` if the user backed out.
class ZainCashCheckoutScreen extends StatefulWidget {
  const ZainCashCheckoutScreen({
    super.key,
    required this.checkout,
    this.service,
  });

  final ZainCashCheckout checkout;
  final ZainCashService? service;

  @override
  State<ZainCashCheckoutScreen> createState() => _ZainCashCheckoutScreenState();
}

class _ZainCashCheckoutScreenState extends State<ZainCashCheckoutScreen> {
  late final ZainCashService _service;
  late final WebViewController _controller;
  bool _loading = true;
  bool _settling = false;
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? ZainCashService();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _loading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
          onNavigationRequest: (request) {
            if (request.url.startsWith(ZainCashConfig.returnUrlPrefix)) {
              _settle();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkout.payUrl));
  }

  /// The backend has already verified the gateway token and updated the order;
  /// we just read the resulting status as the source of truth.
  Future<void> _settle() async {
    if (_handled) return;
    _handled = true;
    if (mounted) setState(() => _settling = true);

    final result = await _service.fetchOrderStatus(widget.checkout.orderId);
    if (!mounted) return;

    switch (result) {
      case Success(:final value):
        Navigator.of(context).pop(value);
      case Failure():
        // Couldn't read status — report as pending so the caller doesn't
        // assume success.
        Navigator.of(context).pop(
          const ZainCashOrderStatus(status: 'pending'),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ZainCash')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading || _settling)
            const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
