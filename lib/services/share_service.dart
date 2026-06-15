import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/deep_link_constants.dart';
import '../core/utils/listing_display_title.dart';
import '../shared/models/listing_model.dart';
import '../shared/models/profile_model.dart';

/// Captures off-screen share cards and opens the system share sheet.
class ShareService {
  ShareService._();

  static Future<void> shareListingToWhatsApp({
    required GlobalKey repaintKey,
    required ListingModel listing,
  }) async {
    final bytes = await _capturePng(repaintKey);

    final tempDir = await getTemporaryDirectory();
    final ref = listing.referenceNo ?? listing.id.hashCode.abs();
    final file = File('${tempDir.path}/sello_share_$ref.png');
    await file.writeAsBytes(bytes);

    final title = listingDisplayTitle(listing);
    final link = listing.referenceNo != null
        ? DeepLinkConstants.listingUrl(listing.referenceNo!)
        : '${DeepLinkConstants.baseUrl}/listing/${listing.id}';

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: '$title\n${listing.formattedPrice} د.ع\n'
            'شاهد الإعلان على سيلو:\n$link',
      ),
    );
  }

  static Future<void> shareProfileCard({
    required GlobalKey repaintKey,
    required ProfileModel profile,
    required int listingCount,
  }) async {
    final bytes = await _capturePng(repaintKey);

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/sello_profile_${profile.id}.png');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'تصفح إعلاناتي على سيلو:\n'
            '${DeepLinkConstants.sellerUrl(profile.id)}',
      ),
    );
  }

  static Future<List<int>> _capturePng(GlobalKey repaintKey) async {
    final boundary = repaintKey.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('Share card is not ready for capture');
    }

    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode share card image');
    }
    return byteData.buffer.asUint8List();
  }
}

/// First listing photo URL for the share card.
String? listingShareImageUrl(ListingModel listing) {
  if (listing.coverImageUrl != null && listing.coverImageUrl!.isNotEmpty) {
    return listing.coverImageUrl;
  }
  if (listing.images.isNotEmpty) {
    final first = listing.images.first;
    final url = first.url ?? first.storagePath;
    if (url.isNotEmpty) return url;
  }
  return null;
}
