import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Decode size in physical pixels for [CachedNetworkImage] memory cache.
int? memCachePx(BuildContext context, double logicalSize) {
  if (logicalSize <= 0 || !logicalSize.isFinite) return null;
  return (logicalSize * MediaQuery.devicePixelRatioOf(context)).round();
}

/// Listing thumbnail with memory-cache dimensions sized to the on-screen slot.
Widget cachedListingImage({
  required BuildContext context,
  required String imageUrl,
  required double width,
  required double height,
  BoxFit fit = BoxFit.cover,
  Widget Function(BuildContext, String)? placeholder,
  Widget Function(BuildContext, String, Object)? errorWidget,
}) {
  return CachedNetworkImage(
    imageUrl: imageUrl,
    fit: fit,
    memCacheWidth: memCachePx(context, width),
    memCacheHeight: memCachePx(context, height),
    placeholder: placeholder,
    errorWidget: errorWidget,
  );
}
