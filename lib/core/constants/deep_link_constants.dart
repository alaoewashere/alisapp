/// Public web URLs opened via universal / app links.
abstract final class DeepLinkConstants {
  DeepLinkConstants._();

  static const host = 'sello.iq';
  static const baseUrl = 'https://sello.iq';

  static String listingPath(int referenceNo) => '/listing/$referenceNo';

  static String listingUrl(int referenceNo) =>
      '$baseUrl${listingPath(referenceNo)}';

  static String sellerPath(String userId) => '/seller/$userId';

  static String sellerUrl(String userId) => '$baseUrl${sellerPath(userId)}';
}
