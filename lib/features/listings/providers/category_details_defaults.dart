import '../../../shared/models/animal_listing_metadata.dart';
import '../../../shared/models/electronics_listing_metadata.dart';
import '../../../shared/models/general_listing_metadata.dart';
import '../../../shared/models/home_service_listing_metadata.dart';
import '../../../shared/models/job_listing_metadata.dart';
import '../../../shared/models/real_estate_listing_metadata.dart';
import '../../../shared/models/tutoring_listing_metadata.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';
import 'post_listing_provider.dart';

abstract final class CategoryDetailsDefaults {
  static const vehicle = VehicleListingMetadata();
  static const realEstate = RealEstateListingMetadata();
  static const electronics = ElectronicsListingMetadata();
  static const general = GeneralListingMetadata();
  static const tutoring = TutoringListingMetadata();
  static const job = JobListingMetadata();
  static const animal = AnimalListingMetadata();
  static const homeService = HomeServiceListingMetadata();

  static PostListingState withEmptyCategoryDetails(
    PostListingState state, {
    VehicleListingMetadata? vehicleDetails,
    RealEstateListingMetadata? realEstateDetails,
    ElectronicsListingMetadata? electronicsDetails,
    GeneralListingMetadata? generalDetails,
    TutoringListingMetadata? tutoringDetails,
    JobListingMetadata? jobDetails,
    AnimalListingMetadata? animalDetails,
    HomeServiceListingMetadata? homeServiceDetails,
  }) {
    return state.copyWith(
      vehicleDetails: vehicleDetails ?? vehicle,
      realEstateDetails: realEstateDetails ?? realEstate,
      electronicsDetails: electronicsDetails ?? electronics,
      generalDetails: generalDetails ?? general,
      tutoringDetails: tutoringDetails ?? tutoring,
      jobDetails: jobDetails ?? job,
      animalDetails: animalDetails ?? animal,
      homeServiceDetails: homeServiceDetails ?? homeService,
    );
  }
}
