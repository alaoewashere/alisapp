import '../../core/constants/app_governorates.dart';
import '../../shared/models/listing_model.dart';

/// Primary location line for listing cards and list tiles.
///
/// When [ListingModel.areaName] is set (neighborhood heat-map / step 3 picker),
/// show it first so area-filtered search results match what users expect.
String listingLocationLabel(ListingModel listing) {
  final area = listing.areaName?.trim();
  if (area != null && area.isNotEmpty) return area;

  final address = listing.locationAddress?.trim();
  if (address != null && address.isNotEmpty) return address;

  final city = listing.city.trim();
  if (city.isNotEmpty) return city;

  return governorateNameAr(listing.governorate);
}
