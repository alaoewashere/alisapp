import '../constants/deep_link_constants.dart';

sealed class DeepLinkTarget {
  const DeepLinkTarget();
}

final class ListingDeepLink extends DeepLinkTarget {
  const ListingDeepLink(this.referenceNo);

  final int referenceNo;
}

final class SellerDeepLink extends DeepLinkTarget {
  const SellerDeepLink(this.sellerId);

  final String sellerId;
}

/// Parses incoming URIs for listing and seller navigation.
abstract final class DeepLinkService {
  DeepLinkService._();

  static DeepLinkTarget? resolve(Uri uri) {
    if (!_isSelloUri(uri)) return null;

    final segments = _pathSegments(uri);
    if (segments.isEmpty) return null;

    switch (segments.first) {
      case 'listing':
        if (segments.length < 2) return null;
        final referenceNo = int.tryParse(segments[1]);
        if (referenceNo == null) return null;
        return ListingDeepLink(referenceNo);
      case 'seller':
        if (segments.length < 2) return null;
        final sellerId = segments[1].trim();
        if (sellerId.isEmpty) return null;
        return SellerDeepLink(sellerId);
      default:
        return null;
    }
  }

  static bool _isSelloUri(Uri uri) {
    if (uri.scheme == 'https' || uri.scheme == 'http') {
      final host = uri.host.toLowerCase();
      return host == DeepLinkConstants.host ||
          host == 'www.${DeepLinkConstants.host}';
    }
    return uri.scheme == DeepLinkConstants.host;
  }

  static List<String> _pathSegments(Uri uri) {
    final host = uri.host.toLowerCase();
    final isWebHost = host == DeepLinkConstants.host ||
        host == 'www.${DeepLinkConstants.host}';

    if (isWebHost) {
      return uri.pathSegments.where((s) => s.isNotEmpty).toList();
    }

    // Custom scheme e.g. sello.iq://listing/1000001
    if (uri.scheme == DeepLinkConstants.host && uri.host.isNotEmpty) {
      return [
        uri.host,
        ...uri.pathSegments.where((s) => s.isNotEmpty),
      ];
    }

    return uri.pathSegments.where((s) => s.isNotEmpty).toList();
  }

  static String routeFor(DeepLinkTarget target) {
    return switch (target) {
      ListingDeepLink(:final referenceNo) =>
        DeepLinkConstants.listingPath(referenceNo),
      SellerDeepLink(:final sellerId) => DeepLinkConstants.sellerPath(sellerId),
    };
  }
}
