/// Electronics listing metadata stored in `listings.metadata` JSONB.
class ElectronicsListingMetadata {
  const ElectronicsListingMetadata({
    this.listingKind,
    this.brand,
    this.model,
    this.storage,
    this.ram,
    this.color,
    this.condition,
    this.batteryHealth,
    this.hasBox,
    this.hasCharger,
    this.warranty,
    this.processor,
    this.screenSize,
    this.resolution,
    this.smart,
  });

  static const listingKindKey = 'listing_kind';
  static const phoneKind = 'phone';
  static const laptopKind = 'laptop';
  static const tvKind = 'tv';

  final String? listingKind;
  final String? brand;
  final String? model;
  final String? storage;
  final String? ram;
  final String? color;
  final String? condition;
  final String? batteryHealth;
  final bool? hasBox;
  final bool? hasCharger;
  final String? warranty;
  final String? processor;
  final String? screenSize;
  final String? resolution;
  final bool? smart;

  ElectronicsListingMetadata copyWith({
    String? listingKind,
    bool clearListingKind = false,
    String? brand,
    bool clearBrand = false,
    String? model,
    bool clearModel = false,
    String? storage,
    bool clearStorage = false,
    String? ram,
    bool clearRam = false,
    String? color,
    bool clearColor = false,
    String? condition,
    bool clearCondition = false,
    String? batteryHealth,
    bool clearBatteryHealth = false,
    bool? hasBox,
    bool? hasCharger,
    String? warranty,
    bool clearWarranty = false,
    String? processor,
    bool clearProcessor = false,
    String? screenSize,
    bool clearScreenSize = false,
    String? resolution,
    bool clearResolution = false,
    bool? smart,
  }) {
    return ElectronicsListingMetadata(
      listingKind:
          clearListingKind ? null : (listingKind ?? this.listingKind),
      brand: clearBrand ? null : (brand ?? this.brand),
      model: clearModel ? null : (model ?? this.model),
      storage: clearStorage ? null : (storage ?? this.storage),
      ram: clearRam ? null : (ram ?? this.ram),
      color: clearColor ? null : (color ?? this.color),
      condition: clearCondition ? null : (condition ?? this.condition),
      batteryHealth:
          clearBatteryHealth ? null : (batteryHealth ?? this.batteryHealth),
      hasBox: hasBox ?? this.hasBox,
      hasCharger: hasCharger ?? this.hasCharger,
      warranty: clearWarranty ? null : (warranty ?? this.warranty),
      processor: clearProcessor ? null : (processor ?? this.processor),
      screenSize: clearScreenSize ? null : (screenSize ?? this.screenSize),
      resolution: clearResolution ? null : (resolution ?? this.resolution),
      smart: smart ?? this.smart,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (listingKind != null) listingKindKey: listingKind,
      if (brand != null) 'brand': brand,
      if (model != null) 'model': model,
      if (storage != null) 'storage': storage,
      if (ram != null) 'ram': ram,
      if (color != null) 'color': color,
      if (condition != null) 'condition': condition,
      if (batteryHealth != null) 'battery_health': batteryHealth,
      if (hasBox != null) 'has_box': hasBox,
      if (hasCharger != null) 'has_charger': hasCharger,
      if (warranty != null) 'warranty': warranty,
      if (processor != null) 'processor': processor,
      if (screenSize != null) 'screen_size': screenSize,
      if (resolution != null) 'resolution': resolution,
      if (smart != null) 'smart': smart,
    };
  }

  factory ElectronicsListingMetadata.fromJson(Map<String, dynamic> json) {
    return ElectronicsListingMetadata(
      listingKind: json[listingKindKey] as String?,
      brand: json['brand'] as String?,
      model: json['model'] as String?,
      storage: json['storage'] as String?,
      ram: json['ram'] as String?,
      color: json['color'] as String?,
      condition: json['condition'] as String?,
      batteryHealth: json['battery_health'] as String?,
      hasBox: json['has_box'] as bool?,
      hasCharger: json['has_charger'] as bool?,
      warranty: json['warranty'] as String?,
      processor: json['processor'] as String?,
      screenSize: json['screen_size'] as String?,
      resolution: json['resolution'] as String?,
      smart: json['smart'] as bool?,
    );
  }

  static ElectronicsListingMetadata? fromMetadataMap(
    Map<String, dynamic>? json,
  ) {
    if (json == null || json.isEmpty) return null;
    final kind = json[listingKindKey] as String?;
    if (kind != phoneKind && kind != laptopKind && kind != tvKind) {
      return null;
    }
    return ElectronicsListingMetadata.fromJson(json);
  }
}

enum ElectronicsFormKind { phone, laptop, tv, none }
