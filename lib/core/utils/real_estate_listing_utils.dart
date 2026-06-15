import '../../shared/models/category_model.dart';
import '../../shared/models/listing_model.dart';
import '../../shared/models/real_estate_listing_metadata.dart';

bool isRealEstateCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == 'real_estate';
}

String buildRealEstateListingTitle(
  List<CategoryModel> path,
  RealEstateListingMetadata details,
) {
  final type = details.propertyType;
  if (type == null || type.isEmpty) {
    return path.isNotEmpty ? path.last.nameAr : 'إعلان عقاري';
  }

  final parts = <String>[type];
  if (details.rooms != null && details.rooms!.isNotEmpty) {
    parts.add('${details.rooms} غرف');
  }
  if (details.areaSqm != null) {
    parts.add('${details.areaSqm} م²');
  }
  return parts.join(' — ');
}

String buildRealEstateListingDescription(RealEstateListingMetadata details) {
  final lines = <String>[];

  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

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
  if (details.features.isNotEmpty) {
    lines.add('المميزات: ${details.features.join('، ')}');
  }

  return lines.isEmpty ? 'إعلان عقاري' : lines.join('\n');
}

Map<String, dynamic> realEstateMetadataForStorage(
  RealEstateListingMetadata details,
) {
  return details.toJson();
}

/// Maps metadata offer type to DB `listing_type` column.
String realEstateDbListingType(String? offerType) {
  return offerType == 'بيع' ? ListingType.sale.value : ListingType.rent.value;
}

ListingType realEstateListingTypeEnum(String? offerType) {
  return offerType == 'بيع' ? ListingType.sale : ListingType.rent;
}
