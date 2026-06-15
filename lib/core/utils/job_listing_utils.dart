import '../../shared/models/category_model.dart';
import '../../shared/models/job_listing_metadata.dart';

const jobsRootSlug = 'jobs';

bool isJobCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == jobsRootSlug;
}

JobListingMetadata deriveJobDetailsFromPath(List<CategoryModel> path) {
  String? sector;
  if (path.length >= 2 && path[1].icon == 'category') {
    sector = path[1].nameAr;
  }
  return JobListingMetadata(sector: sector);
}

String buildJobListingTitle(
  List<CategoryModel> path,
  JobListingMetadata details,
) {
  if (details.sector != null && details.sector!.isNotEmpty) {
    return 'وظيفة — ${details.sector}';
  }
  return path.isNotEmpty ? path.last.nameAr : 'فرصة عمل';
}

String buildJobListingDescription(JobListingMetadata details) {
  final lines = <String>[];
  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('نوع الدوام', details.jobType);
  add('القطاع', details.sector);
  add('الخبرة المطلوبة', details.experienceRequired);
  add('المؤهل المطلوب', details.educationRequired);
  add('تفضيل الجنس', details.genderPreference);
  add('نوع الراتب', details.salaryType);
  if (details.salaryMin != null) {
    lines.add('الراتب من: ${details.salaryMin} د.ع');
  }
  if (details.salaryMax != null) {
    lines.add('الراتب إلى: ${details.salaryMax} د.ع');
  }
  if (details.benefits.isNotEmpty) {
    lines.add('المزايا: ${details.benefits.join('، ')}');
  }

  return lines.isEmpty ? 'فرصة عمل' : lines.join('\n');
}

Map<String, dynamic> jobMetadataForStorage(JobListingMetadata details) {
  return details.toJson();
}
