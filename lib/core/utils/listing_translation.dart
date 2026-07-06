import '../../services/translation_service.dart';
import '../../shared/models/listing_model.dart';
import 'listing_display_title.dart';

/// Translates listing titles and descriptions before they reach the UI.
Future<List<ListingModel>> translateListingsForLocale(
  List<ListingModel> listings,
  String localeCode,
) async {
  if (localeCode == 'ar' || listings.isEmpty) return listings;
  return Future.wait(
    listings.map((listing) => translateListingForLocale(listing, localeCode)),
  );
}

Future<ListingModel> translateListingForLocale(
  ListingModel listing,
  String localeCode,
) async {
  if (localeCode == 'ar') return listing;

  final titleSource = listing.titleAr.trim().isNotEmpty
      ? listing.titleAr.trim()
      : buildListingFallbackTitle(listing);
  final descSource = listing.descriptionAr.trim();

  final translatedTitle = titleSource.isEmpty
      ? titleSource
      : await TranslationService.translate(titleSource, localeCode);
  final translatedDesc = descSource.isEmpty
      ? descSource
      : await TranslationService.translate(descSource, localeCode);

  if (translatedTitle == listing.titleAr &&
      translatedDesc == listing.descriptionAr) {
    return listing;
  }

  return listing.copyWith(
    titleAr: translatedTitle,
    descriptionAr: translatedDesc,
  );
}
