import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../shared/models/listing_model.dart';

const _shareBaseUrl = 'https://souqiq.com/listing';

Future<void> shareListingUrl(ListingModel listing) async {
  final text = StringBuffer()
    ..writeln(listing.titleAr)
    ..writeln(listing.formattedPrice)
    ..write('$_shareBaseUrl/${listing.id}');

  final imageUrl = listing.coverImageUrl ??
      (listing.images.isNotEmpty
          ? (listing.images.first.url ?? listing.images.first.storagePath)
          : null);

  List<XFile>? files;
  if (imageUrl != null && imageUrl.isNotEmpty) {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(imageUrl));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await response.fold<List<int>>(
          <int>[],
          (previous, element) => previous..addAll(element),
        );
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/share_${listing.id}.jpg')
          ..writeAsBytesSync(bytes);
        files = [XFile(file.path)];
      }
      client.close(force: true);
    } catch (_) {
      // Share text-only if image fetch fails.
    }
  }

  await SharePlus.instance.share(
    ShareParams(text: text.toString(), files: files),
  );
}
