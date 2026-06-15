import '../../features/listings/constants/home_service_listing_options.dart';
import '../../shared/models/category_model.dart';
import '../../shared/models/home_service_listing_metadata.dart';

const homeHelpRootSlug = 'home_help';

bool isHomeServiceCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == homeHelpRootSlug;
}

HomeServiceListingMetadata deriveHomeServiceDetailsFromPath(
  List<CategoryModel> path,
) {
  String? serviceType;
  for (final category in path) {
    final mapped = HomeServiceListingOptions.branchSlugToService[category.slug];
    if (mapped != null) serviceType = mapped;
  }
  if (serviceType == null && path.length >= 2) {
    serviceType = path[1].nameAr;
  }
  if (path.isNotEmpty && path.last.icon == 'model') {
    serviceType ??= path.last.nameAr;
  }
  return HomeServiceListingMetadata(serviceType: serviceType);
}

/// Merges user-entered fields with service type from the category breadcrumb.
HomeServiceListingMetadata homeServiceDetailsForStorage(
  List<CategoryModel> path,
  HomeServiceListingMetadata details,
) {
  final fromPath = deriveHomeServiceDetailsFromPath(path);
  return details.copyWith(serviceType: fromPath.serviceType);
}

String buildHomeServiceListingTitle(
  List<CategoryModel> path,
  HomeServiceListingMetadata details,
) {
  if (details.serviceType != null && details.serviceType!.isNotEmpty) {
    return 'خدمة ${details.serviceType}';
  }
  return path.isNotEmpty ? path.last.nameAr : 'مساعدة منزلية';
}

String buildHomeServiceListingDescription(HomeServiceListingMetadata details) {
  final lines = <String>[];
  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('نوع الخدمة', details.serviceType);
  add('الجنس', details.gender);
  add('الجنسية', details.nationality);
  add('أوقات العمل', details.availability);
  if (details.daysPerWeek != null) {
    lines.add('أيام الأسبوع: ${details.daysPerWeek}');
  }
  if (details.experienceYears != null) {
    lines.add('سنوات الخبرة: ${details.experienceYears}');
  }
  if (details.salaryExpected != null) {
    lines.add('الراتب المتوقع: ${details.salaryExpected} د.ع');
  }
  if (details.languages.isNotEmpty) {
    lines.add('اللغات: ${details.languages.join('، ')}');
  }

  return lines.isEmpty ? 'مساعدة منزلية' : lines.join('\n');
}

Map<String, dynamic> homeServiceMetadataForStorage(
  HomeServiceListingMetadata details,
) {
  return details.toJson();
}
