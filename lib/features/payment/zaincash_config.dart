/// Client-side ZainCash settings.
///
/// IMPORTANT: there is no merchant secret here on purpose. Signing the gateway
/// JWT and deciding whether a payment succeeded both happen server-side, in the
/// `zaincash-init` / `zaincash-callback` Supabase edge functions. The app only:
///   1. asks the backend to start a transaction,
///   2. opens the returned hosted pay URL in a WebView, and
///   3. detects the redirect back to [returnUrlPrefix] to close the sheet,
///      then re-reads the authoritative status from the `zaincash_orders` table.
class ZainCashConfig {
  const ZainCashConfig._();

  /// Name of the edge function that creates a transaction.
  static const String initFunction = 'zaincash-init';

  /// Database table holding the authoritative order status.
  static const String ordersTable = 'zaincash_orders';

  /// The WebView is done once ZainCash (via our callback) redirects to a URL
  /// starting with this prefix. Must match `ZAINCASH_RETURN_URL` on the server.
  static const String returnUrlPrefix = 'https://sello.app/zaincash/return';
}
