import '../../../core/utils/listing_display_title.dart';
import '../../../shared/models/listing_model.dart';

/// Strips tashkeel and normalizes common Arabic letter variants for matching.
String normalizeForHomeSearch(String input) {
  var s = input.trim();
  s = s.replaceAll(
    RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'),
    '',
  );
  s = s.toLowerCase();
  const replacements = <String, String>{
    'أ': 'ا',
    'إ': 'ا',
    'آ': 'ا',
    'ٱ': 'ا',
    'ى': 'ي',
    'ئ': 'ي',
    'ة': 'ه',
    'ؤ': 'و',
  };
  for (final entry in replacements.entries) {
    s = s.replaceAll(entry.key, entry.value);
  }
  return s;
}

bool listingTitleMatchesHomeSearch(ListingModel listing, String query) {
  final normalizedQuery = normalizeForHomeSearch(query);
  if (normalizedQuery.isEmpty) return true;
  final title = normalizeForHomeSearch(listingDisplayTitle(listing));
  return title.contains(normalizedQuery);
}

List<ListingModel> filterHomeListingsByTitle(
  List<ListingModel> listings,
  String query,
) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return listings;
  return listings
      .where((listing) => listingTitleMatchesHomeSearch(listing, trimmed))
      .toList();
}
