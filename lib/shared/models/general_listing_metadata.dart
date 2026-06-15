/// General marketplace listing metadata stored in `listings.metadata` JSONB.
class GeneralListingMetadata {
  const GeneralListingMetadata({
    this.listingKind = generalKind,
    this.itemCondition,
    this.brand,
    this.exchangePossible,
    this.deliveryAvailable,
    this.deliveryCost,
  });

  static const listingKindKey = 'listing_kind';
  static const generalKind = 'general';

  final String listingKind;
  final String? itemCondition;
  final String? brand;
  final bool? exchangePossible;
  final bool? deliveryAvailable;
  final String? deliveryCost;

  GeneralListingMetadata copyWith({
    String? listingKind,
    String? itemCondition,
    bool clearItemCondition = false,
    String? brand,
    bool clearBrand = false,
    bool? exchangePossible,
    bool? deliveryAvailable,
    String? deliveryCost,
    bool clearDeliveryCost = false,
  }) {
    return GeneralListingMetadata(
      listingKind: listingKind ?? this.listingKind,
      itemCondition:
          clearItemCondition ? null : (itemCondition ?? this.itemCondition),
      brand: clearBrand ? null : (brand ?? this.brand),
      exchangePossible: exchangePossible ?? this.exchangePossible,
      deliveryAvailable: deliveryAvailable ?? this.deliveryAvailable,
      deliveryCost:
          clearDeliveryCost ? null : (deliveryCost ?? this.deliveryCost),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      listingKindKey: listingKind,
      if (itemCondition != null) 'item_condition': itemCondition,
      if (brand != null && brand!.trim().isNotEmpty) 'brand': brand!.trim(),
      if (exchangePossible != null) 'exchange_possible': exchangePossible,
      if (deliveryAvailable != null) 'delivery_available': deliveryAvailable,
      if (deliveryAvailable == true && deliveryCost != null)
        'delivery_cost': deliveryCost,
    };
  }

  factory GeneralListingMetadata.fromJson(Map<String, dynamic> json) {
    return GeneralListingMetadata(
      listingKind: json[listingKindKey] as String? ?? generalKind,
      itemCondition: json['item_condition'] as String?,
      brand: json['brand'] as String?,
      exchangePossible: json['exchange_possible'] as bool?,
      deliveryAvailable: json['delivery_available'] as bool?,
      deliveryCost: json['delivery_cost'] as String?,
    );
  }

  static GeneralListingMetadata? fromMetadataMap(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;
    if (json[listingKindKey] != generalKind) return null;
    return GeneralListingMetadata.fromJson(json);
  }
}
