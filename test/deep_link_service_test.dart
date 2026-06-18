import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/deep_link_constants.dart';
import 'package:Sello/core/deep_links/deep_link_service.dart';

void main() {
  group('DeepLinkService', () {
    test('resolves listing URL by reference number', () {
      final target = DeepLinkService.resolve(
        Uri.parse('https://sello.iq/listing/1000001'),
      );

      expect(target, isA<ListingDeepLink>());
      expect((target as ListingDeepLink).referenceNo, 1000001);
      expect(
        DeepLinkService.routeFor(target),
        DeepLinkConstants.listingPath(1000001),
      );
    });

    test('resolves seller URL', () {
      final target = DeepLinkService.resolve(
        Uri.parse('https://sello.iq/seller/user-abc-123'),
      );

      expect(target, isA<SellerDeepLink>());
      expect((target as SellerDeepLink).sellerId, 'user-abc-123');
      expect(
        DeepLinkService.routeFor(target),
        DeepLinkConstants.sellerPath('user-abc-123'),
      );
    });

    test('ignores unrelated hosts', () {
      expect(
        DeepLinkService.resolve(Uri.parse('https://example.com/listing/1')),
        isNull,
      );
    });

    test('ignores UUID listing paths', () {
      expect(
        DeepLinkService.resolve(
          Uri.parse(
            'https://sello.iq/listing/550e8400-e29b-41d4-a716-446655440000',
          ),
        ),
        isNull,
      );
    });
  });

  group('DeepLinkConstants', () {
    test('builds listing and seller URLs', () {
      expect(
        DeepLinkConstants.listingUrl(42),
        'https://sello.iq/listing/42',
      );
      expect(
        DeepLinkConstants.sellerUrl('uid'),
        'https://sello.iq/seller/uid',
      );
    });
  });
}
