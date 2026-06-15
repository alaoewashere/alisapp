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

ListingMetadataDisplay buildListingMetadataDisplay(ListingModel listing) {
  if (listing.vehicleMetadata != null) {
    return _vehicleDisplay(listing.vehicleMetadata!, listing.condition);
  }
  if (listing.realEstateMetadata != null) {
    return _realEstateDisplay(listing.realEstateMetadata!);
  }
  if (listing.electronicsMetadata != null) {
    return _electronicsDisplay(listing.electronicsMetadata!);
  }
  if (listing.generalMetadata != null) {
    return _generalDisplay(listing.generalMetadata!);
  }
  if (listing.tutoringMetadata != null) {
    return _tutoringDisplay(listing.tutoringMetadata!);
  }
  if (listing.jobMetadata != null) {
    return _jobDisplay(listing.jobMetadata!);
  }
  if (listing.animalMetadata != null) {
    return _animalDisplay(listing.animalMetadata!);
  }
  if (listing.homeServiceMetadata != null) {
    return _homeServiceDisplay(listing.homeServiceMetadata!);
  }
  return const ListingMetadataDisplay();
}

ListingMetadataDisplay _vehicleDisplay(
  VehicleListingMetadata vehicle,
  ListingCondition? condition,
) {
  return ListingMetadataDisplay(
    rows: vehicleDetailRows(vehicle, condition),
    chipGroups: vehicle.selectedSpecs.isEmpty
        ? const []
        : [
            MetadataChipGroup(
              title: 'المواصفات',
              chips: vehicle.selectedSpecs,
            ),
          ],
  );
}

ListingMetadataDisplay _realEstateDisplay(RealEstateListingMetadata details) {
  final rows = _rows((add) {
    add('نوع العقار', details.propertyType);
    add('نوع العرض', details.offerType);
    if (details.areaSqm != null) add('المساحة', '${details.areaSqm} م²');
    if (details.floor != null) add('الطابق', details.floor.toString());
    if (details.totalFloors != null) {
      add('عدد الطوابق', details.totalFloors.toString());
    }
    add('عدد الغرف', details.rooms);
    add('عدد الحمامات', details.bathrooms);
    add('عمر البناء', details.ageYears);
    add('التشطيب', details.furnished);
    add('نوع الصك', details.deedType);
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.features.isEmpty
        ? const []
        : [MetadataChipGroup(title: 'المميزات', chips: details.features)],
  );
}

ListingMetadataDisplay _electronicsDisplay(ElectronicsListingMetadata details) {
  final rows = _rows((add) {
    add('الماركة', details.brand);
    add('الموديل', details.model);
    add('التخزين', details.storage);
    add('الرام', details.ram);
    add('اللون', details.color);
    add('الحالة', details.condition);
    add('صحة البطارية', details.batteryHealth);
    add('الضمان', details.warranty);
    add('المعالج', details.processor);
    if (details.screenSize != null) {
      add('حجم الشاشة', '${details.screenSize}"');
    }
    add('الدقة', details.resolution);
    add('مع العلبة', _boolLabel(details.hasBox));
    add('مع الشاحن', _boolLabel(details.hasCharger));
    add('سمارت TV', _boolLabel(details.smart));
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _generalDisplay(GeneralListingMetadata details) {
  final rows = _rows((add) {
    add('الحالة', details.itemCondition);
    add('الماركة', details.brand);
    add('قابل للتبادل', _boolLabel(details.exchangePossible));
    add('توصيل متاح', _boolLabel(details.deliveryAvailable));
    add('تكلفة التوصيل', details.deliveryCost);
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _tutoringDisplay(TutoringListingMetadata details) {
  final rows = _rows((add) {
    add('المادة', details.subject);
    add('المنهج', details.curriculum);
    add('طريقة التدريس', details.sessionType);
    add('الجنس المقبول', details.gender);
    if (details.pricePerHour != null) {
      add('السعر/ساعة', '${details.pricePerHour} د.ع');
    }
    if (details.experienceYears != null) {
      add('سنوات الخبرة', details.experienceYears.toString());
    }
    add('المؤهل العلمي', details.qualifications);
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.stages.isEmpty
        ? const []
        : [MetadataChipGroup(title: 'المراحل الدراسية', chips: details.stages)],
  );
}

ListingMetadataDisplay _jobDisplay(JobListingMetadata details) {
  final rows = _rows((add) {
    add('نوع الدوام', details.jobType);
    add('القطاع', details.sector);
    add('الخبرة المطلوبة', details.experienceRequired);
    add('المؤهل المطلوب', details.educationRequired);
    add('تفضيل الجنس', details.genderPreference);
    add('نوع الراتب', details.salaryType);
    if (details.salaryMin != null) {
      add('الراتب الأدنى', '${details.salaryMin} د.ع');
    }
    if (details.salaryMax != null) {
      add('الراتب الأعلى', '${details.salaryMax} د.ع');
    }
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.benefits.isEmpty
        ? const []
        : [MetadataChipGroup(title: 'المزايا', chips: details.benefits)],
  );
}

ListingMetadataDisplay _animalDisplay(AnimalListingMetadata details) {
  final rows = _rows((add) {
    add('نوع الحيوان', details.animalType);
    add('السلالة', details.breed);
    if (details.ageMonths != null) {
      add('العمر', '${details.ageMonths} شهر');
    }
    add('الجنس', details.gender);
    add('ملقح', _boolLabel(details.vaccinated));
    add('يمتلك وثائق', _boolLabel(details.hasPapers));
    add('مدرب', _boolLabel(details.trained));
    add('اللون', details.color);
  });
  return ListingMetadataDisplay(rows: rows);
}

ListingMetadataDisplay _homeServiceDisplay(HomeServiceListingMetadata details) {
  final rows = _rows((add) {
    add('نوع الخدمة', details.serviceType);
    add('الجنس', details.gender);
    add('الجنسية', details.nationality);
    add('أوقات العمل', details.availability);
    if (details.daysPerWeek != null) {
      add('أيام الأسبوع', details.daysPerWeek.toString());
    }
    if (details.experienceYears != null) {
      add('سنوات الخبرة', details.experienceYears.toString());
    }
    if (details.salaryExpected != null) {
      add('الراتب المتوقع', '${details.salaryExpected} د.ع');
    }
  });

  return ListingMetadataDisplay(
    rows: rows,
    chipGroups: details.languages.isEmpty
        ? const []
        : [MetadataChipGroup(title: 'اللغات', chips: details.languages)],
  );
}

typedef _RowAdder = void Function(String label, String? value);

List<MapEntry<String, String>> _rows(void Function(_RowAdder add) build) {
  final rows = <MapEntry<String, String>>[];
  build((label, value) {
    if (value == null || value.trim().isEmpty) return;
    rows.add(MapEntry(label, value.trim()));
  });
  return rows;
}

String? _boolLabel(bool? value) {
  if (value == null) return null;
  return value ? 'نعم' : 'لا';
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
