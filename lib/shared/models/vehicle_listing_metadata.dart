/// Vehicle-specific listing fields stored in `listings.metadata` JSONB.
class VehicleListingMetadata {
  const VehicleListingMetadata({
    this.trim = '',
    this.mileage,
    this.mileageUnit = MileageUnit.km,
    this.engine = '',
    this.cylinders,
    this.paintParts,
    this.fuel,
    this.importCountry,
    this.plate,
    this.transmission,
    this.seatNumber,
    this.seatMaterial,
    this.color,
    this.customColor = '',
    this.selectedSpecs = const [],
    this.panelConditions = const {},
  });

  final String trim;
  final int? mileage;
  final MileageUnit mileageUnit;
  final String engine;
  final String? cylinders;
  final String? paintParts;
  final String? fuel;
  final String? importCountry;
  final String? plate;
  final String? transmission;
  final String? seatNumber;
  final String? seatMaterial;
  final String? color;
  final String customColor;
  final List<String> selectedSpecs;

  /// Non-original body panel conditions keyed by panel id (e.g. `hood`).
  final Map<String, String> panelConditions;

  static const listingKindKey = 'listing_kind';
  static const vehicleKind = 'vehicle';

  VehicleListingMetadata copyWith({
    String? trim,
    int? mileage,
    bool clearMileage = false,
    MileageUnit? mileageUnit,
    String? engine,
    String? cylinders,
    bool clearCylinders = false,
    String? paintParts,
    bool clearPaintParts = false,
    String? fuel,
    bool clearFuel = false,
    String? importCountry,
    bool clearImportCountry = false,
    String? plate,
    bool clearPlate = false,
    String? transmission,
    bool clearTransmission = false,
    String? seatNumber,
    bool clearSeatNumber = false,
    String? seatMaterial,
    bool clearSeatMaterial = false,
    String? color,
    bool clearColor = false,
    String? customColor,
    List<String>? selectedSpecs,
    Map<String, String>? panelConditions,
    bool clearPanelConditions = false,
  }) {
    return VehicleListingMetadata(
      trim: trim ?? this.trim,
      mileage: clearMileage ? null : (mileage ?? this.mileage),
      mileageUnit: mileageUnit ?? this.mileageUnit,
      engine: engine ?? this.engine,
      cylinders: clearCylinders ? null : (cylinders ?? this.cylinders),
      paintParts: clearPaintParts ? null : (paintParts ?? this.paintParts),
      fuel: clearFuel ? null : (fuel ?? this.fuel),
      importCountry:
          clearImportCountry ? null : (importCountry ?? this.importCountry),
      plate: clearPlate ? null : (plate ?? this.plate),
      transmission:
          clearTransmission ? null : (transmission ?? this.transmission),
      seatNumber: clearSeatNumber ? null : (seatNumber ?? this.seatNumber),
      seatMaterial:
          clearSeatMaterial ? null : (seatMaterial ?? this.seatMaterial),
      color: clearColor ? null : (color ?? this.color),
      customColor: customColor ?? this.customColor,
      selectedSpecs: selectedSpecs ?? this.selectedSpecs,
      panelConditions: clearPanelConditions
          ? const {}
          : (panelConditions ?? this.panelConditions),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: vehicleKind,
      'trim': trim,
      if (mileage != null) 'mileage': mileage,
      'mileage_unit': mileageUnit.value,
      'engine': engine,
      if (cylinders != null) 'cylinders': cylinders,
      if (paintParts != null) 'paint_parts': paintParts,
      if (fuel != null) 'fuel': fuel,
      if (importCountry != null) 'import_country': importCountry,
      if (plate != null) 'plate': plate,
      if (transmission != null) 'transmission': transmission,
      if (seatNumber != null) 'seat_number': seatNumber,
      if (seatMaterial != null) 'seat_material': seatMaterial,
      if (color != null) 'color': color,
      if (customColor.isNotEmpty) 'custom_color': customColor,
      'selected_specs': selectedSpecs,
      if (panelConditions.isNotEmpty) 'panel_conditions': panelConditions,
    };
  }

  factory VehicleListingMetadata.fromJson(Map<String, dynamic> json) {
    final specs = json['selected_specs'];
    final panelRaw = json['panel_conditions'];
    final panelConditions = panelRaw is Map
        ? panelRaw.map((key, value) => MapEntry(key.toString(), value.toString()))
        : const <String, String>{};
    return VehicleListingMetadata(
      trim: json['trim'] as String? ?? '',
      mileage: (json['mileage'] as num?)?.toInt(),
      mileageUnit: MileageUnit.fromValue(json['mileage_unit'] as String?),
      engine: json['engine'] as String? ?? '',
      cylinders: json['cylinders'] as String?,
      paintParts: json['paint_parts'] as String?,
      fuel: json['fuel'] as String?,
      importCountry: json['import_country'] as String?,
      plate: json['plate'] as String?,
      transmission: json['transmission'] as String?,
      seatNumber: json['seat_number'] as String?,
      seatMaterial: json['seat_material'] as String?,
      color: json['color'] as String?,
      customColor: json['custom_color'] as String? ?? '',
      selectedSpecs: specs is List
          ? specs.map((e) => e.toString()).toList()
          : const [],
      panelConditions: panelConditions,
    );
  }

  static VehicleListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != vehicleKind) return null;
    return VehicleListingMetadata.fromJson(json);
  }
}

enum MileageUnit {
  km('km', 'كم'),
  mile('mile', 'ميل');

  const MileageUnit(this.value, this.labelAr);

  final String value;
  final String labelAr;

  static MileageUnit fromValue(String? value) {
    for (final unit in MileageUnit.values) {
      if (unit.value == value) return unit;
    }
    return MileageUnit.km;
  }
}
