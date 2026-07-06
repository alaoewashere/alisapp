import '../../l10n/app_localizations.dart';
import '../../core/l10n/listing_attribute_locale.dart';
import '../../shared/models/animal_listing_metadata.dart';
import '../../shared/models/electronics_listing_metadata.dart';
import '../../shared/models/general_listing_metadata.dart';
import '../../shared/models/home_service_listing_metadata.dart';
import '../../shared/models/job_listing_metadata.dart';
import '../../shared/models/listing_model.dart';
import '../../shared/models/real_estate_listing_metadata.dart';
import '../../shared/models/tutoring_listing_metadata.dart';
import '../../shared/models/vehicle_listing_metadata.dart';
import 'vehicle_listing_utils.dart';

ListingMetadataDisplay buildListingMetadataDisplay(
  ListingModel listing,
  AppLocalizations l10n,
) {
  if (listing.vehicleMetadata != null) {
    return _vehicleDisplay(listing.vehicleMetadata!, listing.condition, l10n);
  }
  if (listing.realEstateMetadata != null) {
    return _realEstateDisplay(listing.realEstateMetadata!, l10n);
  }
  if (listing.electronicsMetadata != null) {
    return _electronicsDisplay(listing.electronicsMetadata!, l10n);
  }
  if (listing.generalMetadata != null) {
    return _generalDisplay(listing.generalMetadata!, l10n);
  }
  if (listing.tutoringMetadata != null) {
    return _tutoringDisplay(listing.tutoringMetadata!, l10n);
  }
  if (listing.jobMetadata != null) {
    return _jobDisplay(listing.jobMetadata!, l10n);
  }
  if (listing.animalMetadata != null) {
    return _animalDisplay(listing.animalMetadata!, l10n);
  }
  if (listing.homeServiceMetadata != null) {
    return _homeServiceDisplay(listing.homeServiceMetadata!, l10n);
  }
  return const ListingMetadataDisplay();
}

ListingMetadataDisplay _vehicleDisplay(
  VehicleListingMetadata vehicle,
  ListingCondition? condition,
  AppLocalizations l10n,
) {
  return ListingMetadataDisplay(
    rows: vehicleDetailRows(vehicle, condition, l10n),
    chipGroups: vehicle.selectedSpecs.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: l10n.sectionSpecs,
              chips: vehicle.selectedSpecs
                  .map((spec) => localizeListingAttribute(spec, l10n))
                  .toList(),
            ),
          ],
  );
}

ListingMetadataDisplay _realEstateDisplay(
  RealEstateListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaPropertyType, details.propertyType);
    add(l10n.metaOfferType, details.offerType);
    if (details.areaSqm != null) add(l10n.metaArea, '${details.areaSqm} m²');
    if (details.floor != null) add(l10n.metaFloor, details.floor.toString());
    if (details.totalFloors != null) {
      add(l10n.metaTotalFloors, details.totalFloors.toString());
    }
    add(l10n.metaRooms, details.rooms);
    add(l10n.metaBathrooms, details.bathrooms);
    add(l10n.metaBuildingAge, details.ageYears);
    add(l10n.metaFurnishing, details.furnished);
    add(l10n.deedTypeLabel, details.deedType);
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.features.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: l10n.featuresSectionTitle,
              chips: details.features
                  .map((feature) => localizeListingAttribute(feature, l10n))
                  .toList(),
            ),
          ],
  );
}

ListingMetadataDisplay _electronicsDisplay(
  ElectronicsListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaBrand, details.brand);
    add(l10n.metaModel, details.model);
    add(l10n.metaStorage, details.storage);
    add(l10n.metaRam, details.ram);
    add(l10n.fieldColor, details.color);
    add(l10n.fieldCondition, details.condition);
    add(l10n.metaBatteryHealth, details.batteryHealth);
    add(l10n.metaWarranty, details.warranty);
    add(l10n.metaProcessor, details.processor);
    if (details.screenSize != null) {
      add(l10n.metaScreenSize, '${details.screenSize}"');
    }
    add(l10n.metaResolution, details.resolution);
    add(l10n.metaWithBox, _boolLabel(details.hasBox, l10n));
    add(l10n.metaWithCharger, _boolLabel(details.hasCharger, l10n));
    add(l10n.metaSmartTv, _boolLabel(details.smart, l10n));
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _generalDisplay(
  GeneralListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.fieldCondition, details.itemCondition);
    add(l10n.metaBrand, details.brand);
    add(l10n.exchangePossible, _boolLabel(details.exchangePossible, l10n));
    add(l10n.deliveryAvailable, _boolLabel(details.deliveryAvailable, l10n));
    add(l10n.metaDeliveryCost, details.deliveryCost);
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _tutoringDisplay(
  TutoringListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaSubject, details.subject);
    add(l10n.curriculumLabel, details.curriculum);
    add(l10n.metaTeachingMethod, details.sessionType);
    add(l10n.acceptedGenderLabel, details.gender);
    if (details.pricePerHour != null) {
      add(l10n.metaPricePerHour, '${details.pricePerHour} ${l10n.currencyIqd}');
    }
    if (details.experienceYears != null) {
      add(l10n.metaExperience, details.experienceYears.toString());
    }
    add(l10n.metaQualifications, details.qualifications);
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.stages.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: l10n.metaStudyStages,
              chips: details.stages
                  .map((stage) => localizeListingAttribute(stage, l10n))
                  .toList(),
            ),
          ],
  );
}

ListingMetadataDisplay _jobDisplay(
  JobListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaJobType, details.jobType);
    add(l10n.metaSector, details.sector);
    add(l10n.metaExperienceRequired, details.experienceRequired);
    add(l10n.metaEducationRequired, details.educationRequired);
    add(l10n.metaGenderPreference, details.genderPreference);
    add(l10n.salaryTypeLabel, details.salaryType);
    if (details.salaryMin != null) {
      add(l10n.metaSalaryMin, '${details.salaryMin} ${l10n.currencyIqd}');
    }
    if (details.salaryMax != null) {
      add(l10n.metaSalaryMax, '${details.salaryMax} ${l10n.currencyIqd}');
    }
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.benefits.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: l10n.benefitsSectionTitle,
              chips: details.benefits
                  .map((benefit) => localizeListingAttribute(benefit, l10n))
                  .toList(),
            ),
          ],
  );
}

ListingMetadataDisplay _animalDisplay(
  AnimalListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaAnimalType, details.animalType);
    add(l10n.metaBreed, details.breed);
    if (details.ageMonths != null) {
      add(l10n.metaAge, l10n.metaAgeMonths(details.ageMonths!));
    }
    add(l10n.metaGender, details.gender);
    add(l10n.metaVaccinated, _boolLabel(details.vaccinated, l10n));
    add(l10n.metaHasPapers, _boolLabel(details.hasPapers, l10n));
    add(l10n.metaTrained, _boolLabel(details.trained, l10n));
    add(l10n.fieldColor, details.color);
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _homeServiceDisplay(
  HomeServiceListingMetadata details,
  AppLocalizations l10n,
) {
  final rows = _rows(l10n, (add) {
    add(l10n.metaServiceType, details.serviceType);
    add(l10n.metaGender, details.gender);
    add(l10n.nationalityLabel, details.nationality);
    add(l10n.metaWorkHours, details.availability);
    if (details.daysPerWeek != null) {
      add(l10n.metaDaysPerWeek, details.daysPerWeek.toString());
    }
    if (details.experienceYears != null) {
      add(l10n.metaExperience, details.experienceYears.toString());
    }
    if (details.salaryExpected != null) {
      add(l10n.metaExpectedSalary, '${details.salaryExpected} ${l10n.currencyIqd}');
    }
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.languages.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: l10n.languagesSectionTitle,
              chips: details.languages
                  .map((language) => localizeListingAttribute(language, l10n))
                  .toList(),
            ),
          ],
  );
}

typedef _RowAdder = void Function(String label, String? value);

List<MapEntry<String, String>> _rows(
  AppLocalizations l10n,
  void Function(_RowAdder add) build,
) {
  final rows = <MapEntry<String, String>>[];
  build((label, value) {
    if (value == null || value.trim().isEmpty) return;
    rows.add(
      MapEntry(label, localizeListingAttribute(value.trim(), l10n)),
    );
  });
  return rows;
}

String? _boolLabel(bool? value, AppLocalizations l10n) {
  if (value == null) return null;
  return value ? l10n.yesLabel : l10n.noLabel;
}

class MetadataChipGroup {
  const MetadataChipGroup({required this.title, required this.chips});

  final String title;
  final List<String> chips;
}

class ListingMetadataDisplay {
  const ListingMetadataDisplay({
    this.rows = const [],
    this.chipGroups = const [],
  });

  final List<MapEntry<String, String>> rows;
  final List<MetadataChipGroup> chipGroups;

  bool get isEmpty => rows.isEmpty && chipGroups.every((g) => g.chips.isEmpty);
}
