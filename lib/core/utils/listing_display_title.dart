import '../../l10n/app_localizations.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/listing_model.dart';
import 'animal_listing_utils.dart';
import 'electronics_listing_utils.dart';
import 'general_listing_utils.dart';
import 'home_service_listing_utils.dart';
import 'job_listing_utils.dart';
import 'real_estate_listing_utils.dart';
import 'tutoring_listing_utils.dart';
import 'vehicle_listing_utils.dart';

/// User-written title when present; otherwise a metadata-based fallback.
String listingDisplayTitle(ListingModel listing, [AppLocalizations? l10n]) {
  final userTitle = listing.titleAr.trim();
  if (userTitle.isNotEmpty) return userTitle;
  return buildListingFallbackTitle(listing, l10n);
}

/// Builds a basic title from listing metadata for legacy rows with no title.
String buildListingFallbackTitle(ListingModel listing, [AppLocalizations? l10n]) {
  final path = _categoryPathForListing(listing);

  if (listing.isVehicleListing && listing.vehicleMetadata != null) {
    return buildVehicleListingTitle(path, listing.vehicleMetadata!);
  }
  if (listing.isRealEstateListing && listing.realEstateMetadata != null) {
    return buildRealEstateListingTitle(path, listing.realEstateMetadata!);
  }
  if (listing.isElectronicsListing && listing.electronicsMetadata != null) {
    return buildElectronicsListingTitle(path, listing.electronicsMetadata!);
  }
  if (listing.isGeneralMarketplaceListing && listing.generalMetadata != null) {
    return buildGeneralListingTitle(path, listing.generalMetadata!);
  }
  if (listing.isTutoringListing && listing.tutoringMetadata != null) {
    return buildTutoringListingTitle(path, listing.tutoringMetadata!);
  }
  if (listing.isJobListing && listing.jobMetadata != null) {
    return buildJobListingTitle(path, listing.jobMetadata!);
  }
  if (listing.isAnimalListing && listing.animalMetadata != null) {
    return buildAnimalListingTitle(path, listing.animalMetadata!);
  }
  if (listing.isHomeServiceListing && listing.homeServiceMetadata != null) {
    return buildHomeServiceListingTitle(path, listing.homeServiceMetadata!);
  }

  return listing.categoryNameAr?.trim().isNotEmpty == true
      ? listing.categoryNameAr!.trim()
      : (l10n?.listingFallbackTitle ?? 'Listing');
}

List<CategoryModel> _categoryPathForListing(ListingModel listing) {
  final name = listing.categoryNameAr?.trim();
  if (name == null || name.isEmpty) return const [];
  return [
    CategoryModel(
      id: listing.categoryId,
      slug: '',
      nameAr: name,
      icon: 'category',
    ),
  ];
}
