import '../../../features/listings/constants/vehicle_listing_options.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';

/// True when the selected category path is under المركبات (`cars` root).
bool isVehicleCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == 'cars';
}

/// True only for المركبات → سيارات (`veh_automobile`), not trucks/motorcycles/etc.
bool isAutomobileCarListingPath(List<CategoryModel> path) {
  return path.any((c) => c.slug == 'veh_automobile');
}

/// Make, model, and optional model year from the category drill-down path.
({String? make, String? model, String? year}) vehicleIdentityFromPath(
  List<CategoryModel> path,
) {
  String? make;
  String? model;
  String? year;

  for (final category in path) {
    if (category.icon == 'brand') {
      make = category.nameAr;
    } else if (category.icon == 'model') {
      model = category.nameAr;
    } else if (RegExp(r'^(19|20)\d{2}$').hasMatch(category.nameAr.trim())) {
      year = category.nameAr.trim();
    }
  }

  return (make: make, model: model, year: year);
}

/// Builds listing title from vehicle category path + trim.
String buildVehicleListingTitle(
  List<CategoryModel> path,
  VehicleListingMetadata vehicle,
) {
  if (path.isEmpty) return 'إعلان مركبة';
  final leaf = path.last.nameAr;
  if (vehicle.trim.trim().isEmpty) return leaf;
  return '$leaf ${vehicle.trim.trim()}';
}

/// Builds a searchable Arabic description from vehicle metadata.
String buildVehicleListingDescription(VehicleListingMetadata vehicle) {
  final lines = <String>[];

  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('الفئة', vehicle.trim);
  if (vehicle.mileage != null) {
    add(
      'المسافة المقطوعة',
      '${vehicle.mileage} ${vehicle.mileageUnit.labelAr}',
    );
  }
  add('المحرك', vehicle.engine);
  add('عدد الأسطوانات', vehicle.cylinders);
  add('وضع الطلاء', vehicle.paintParts);
  add('الوقود', vehicle.fuel);
  add('بلد الاستيراد', vehicle.importCountry);
  add('اللوحة', vehicle.plate);
  add('ناقل الحركة', vehicle.transmission);
  add('عدد المقاعد', vehicle.seatNumber);
  add('مادة المقاعد', vehicle.seatMaterial);
  if (vehicle.color != null) {
    final colorLabel = VehicleCarColors.isOtherLabel(vehicle.color) &&
            vehicle.customColor.isNotEmpty
        ? vehicle.customColor
        : vehicle.color;
    add('اللون', colorLabel);
  }
  if (vehicle.selectedSpecs.isNotEmpty) {
    lines.add('المواصفات: ${vehicle.selectedSpecs.join('، ')}');
  }

  return lines.isEmpty ? 'إعلان مركبة' : lines.join('\n');
}

ListingCondition? vehicleConditionFromLabel(String? label) {
  return switch (label) {
    'جديد' => ListingCondition.newItem,
    'مستعمل' => ListingCondition.used,
    _ => null,
  };
}

String vehicleConditionLabel(ListingCondition? condition) {
  return switch (condition) {
    ListingCondition.newItem => 'جديد',
    ListingCondition.used => 'مستعمل',
    null => '',
  };
}

Map<String, dynamic> vehicleMetadataForStorage(VehicleListingMetadata vehicle) {
  return vehicle.toJson();
}

/// Formatted mileage for vehicle stat cards (e.g. "22,000 كم").
String formatVehicleMileageDisplay(int mileage, MileageUnit unit) {
  final formatted = mileage.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
      );
  return '$formatted ${unit.labelAr}';
}

/// Cylinder count label for stat card (e.g. "4 أسطوانة").
String formatVehicleCylindersDisplay(String? cylinders) {
  if (cylinders == null || cylinders.isEmpty) return '—';
  if (cylinders == 'كهربائي') return cylinders;
  return '$cylinders أسطوانة';
}

/// Engine label for stat card (e.g. "محرك، 2.0T").
String formatVehicleEngineDisplay(String engine) {
  if (engine.trim().isEmpty) return '—';
  return 'محرك، ${engine.trim()}';
}

/// Whether the vehicle stat row should be shown (any core stat present).
bool hasVehicleCoreStats(VehicleListingMetadata vehicle) {
  return vehicle.trim.isNotEmpty ||
      vehicle.mileage != null ||
      vehicle.engine.isNotEmpty ||
      (vehicle.cylinders != null && vehicle.cylinders!.isNotEmpty);
}

/// Detail rows for vehicle listing (excludes the 4 stat-card fields).
List<MapEntry<String, String>> vehicleDetailRows(
  VehicleListingMetadata vehicle,
  ListingCondition? condition,
) {
  final rows = <MapEntry<String, String>>[];

  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    rows.add(MapEntry(label, value.trim()));
  }

  add('الحالة', vehicleConditionLabel(condition));
  add('وضع الطلاء', vehicle.paintParts);
  add('الوقود', vehicle.fuel);
  add('بلد الاستيراد', vehicle.importCountry);
  add('اللوحة', vehicle.plate);
  add('ناقل الحركة', vehicle.transmission);
  add('عدد المقاعد', vehicle.seatNumber);
  add('مادة المقاعد', vehicle.seatMaterial);

  if (vehicle.color != null) {
    final colorLabel = VehicleCarColors.isOtherLabel(vehicle.color) &&
            vehicle.customColor.isNotEmpty
        ? vehicle.customColor
        : vehicle.color;
    add('اللون', colorLabel);
  }

  return rows;
}
