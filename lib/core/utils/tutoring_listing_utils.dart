import '../../shared/models/category_model.dart';
import '../../shared/models/tutoring_listing_metadata.dart';

const tutoringRootSlug = 'tutoring';

bool isTutoringCategoryPath(List<CategoryModel> path) {
  return path.isNotEmpty && path.first.slug == tutoringRootSlug;
}

TutoringListingMetadata deriveTutoringDetailsFromPath(List<CategoryModel> path) {
  String? subject;
  for (final category in path) {
    if (category.icon == 'model') subject = category.nameAr;
  }
  if (subject == null && path.isNotEmpty && path.last.icon == 'model') {
    subject = path.last.nameAr;
  }
  return TutoringListingMetadata(subject: subject);
}

String buildTutoringListingTitle(
  List<CategoryModel> path,
  TutoringListingMetadata details,
) {
  final subject = details.subject;
  if (subject != null && subject.isNotEmpty) {
    return 'دروس $subject';
  }
  return path.isNotEmpty ? 'دروس ${path.last.nameAr}' : 'درس خصوصي';
}

String buildTutoringListingDescription(TutoringListingMetadata details) {
  final lines = <String>[];
  void add(String label, String? value) {
    if (value == null || value.trim().isEmpty) return;
    lines.add('$label: $value');
  }

  add('المادة', details.subject);
  add('المنهج', details.curriculum);
  if (details.stages.isNotEmpty) {
    lines.add('المراحل: ${details.stages.join('، ')}');
  }
  add('الجنس المقبول', details.gender);
  add('طريقة التدريس', details.sessionType);
  if (details.pricePerHour != null) {
    lines.add('السعر/ساعة: ${details.pricePerHour} د.ع');
  }
  if (details.experienceYears != null) {
    lines.add('سنوات الخبرة: ${details.experienceYears}');
  }
  add('المؤهل', details.qualifications);

  return lines.isEmpty ? 'درس خصوصي' : lines.join('\n');
}

Map<String, dynamic> tutoringMetadataForStorage(
  TutoringListingMetadata details,
) {
  return details.toJson();
}
