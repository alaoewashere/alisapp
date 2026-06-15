import '../../features/listings/constants/animal_listing_options.dart';
import '../../shared/models/animal_listing_metadata.dart';
import '../../shared/models/category_model.dart';

const petsRootSlug = 'pets';

bool isAnimalCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == petsRootSlug;
}

String? _animalTypeFromPath(List<CategoryModel> path) {
  for (final category in path) {
    final mapped = AnimalListingOptions.branchSlugToType[category.slug];
    if (mapped != null) return mapped;
  }
  return null;
}

AnimalListingMetadata deriveAnimalDetailsFromPath(List<CategoryModel> path) {
  final animalType = _animalTypeFromPath(path);
  String? breed;
  for (final category in path) {
    if (category.icon == 'model') breed = category.nameAr;
  }
  if (breed == null && path.isNotEmpty && path.last.icon == 'model') {
    breed = path.last.nameAr;
  }
  return AnimalListingMetadata(animalType: animalType, breed: breed);
}

/// Merges user-entered fields with type/breed from the category breadcrumb.
AnimalListingMetadata animalDetailsForStorage(
  List<CategoryModel> path,
  AnimalListingMetadata details,
) {
  final fromPath = deriveAnimalDetailsFromPath(path);
  return details.copyWith(
    animalType: fromPath.animalType,
    breed: fromPath.breed,
  );
}

String buildAnimalListingTitle(
  List<CategoryModel> path,
  AnimalListingMetadata details,
) {
  final parts = <String>[];
  if (details.breed != null && details.breed!.isNotEmpty) {
    parts.add(details.breed!);
  } else if (details.animalType != null) {
    parts.add(details.animalType!);
  }
  return parts.isNotEmpty ? parts.join(' ') : path.last.nameAr;
}

String buildAnimalListingDescription(AnimalListingMetadata details) {
  final lines = <String>[];
  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('النوع', details.animalType);
  add('السلالة', details.breed);
  if (details.ageMonths != null) {
    lines.add('العمر: ${details.ageMonths} شهر');
  }
  add('الجنس', details.gender);
  if (details.vaccinated == true) lines.add('ملقح');
  if (details.hasPapers == true) lines.add('يمتلك وثائق');
  if (details.trained == true) lines.add('مدرب');
  add('اللون', details.color);

  return lines.isEmpty ? 'إعلان حيوانات' : lines.join('\n');
}

Map<String, dynamic> animalMetadataForStorage(AnimalListingMetadata details) {
  return details.toJson();
}
