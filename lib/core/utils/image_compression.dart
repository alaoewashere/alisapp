import 'dart:io';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Compresses [file] to max [maxWidth] px and ~[maxBytes] size.
Future<File> compressListingImage(
  File file, {
  int maxWidth = 1200,
  int maxBytes = 1024 * 1024,
}) async {
  final dir = await getTemporaryDirectory();
  final targetPath = p.join(
    dir.path,
    'listing_${DateTime.now().millisecondsSinceEpoch}.jpg',
  );

  var quality = 85;
  File? result;

  while (quality >= 40) {
    final bytes = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      minWidth: maxWidth,
      minHeight: maxWidth,
      quality: quality,
      format: CompressFormat.jpeg,
    );
    if (bytes == null) break;

    result = File(targetPath)..writeAsBytesSync(bytes);
    if (bytes.length <= maxBytes) return result;
    quality -= 15;
  }

  return result ?? file;
}
