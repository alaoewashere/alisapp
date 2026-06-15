import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/utils/listing_metadata_detail_rows.dart';
import 'package:my_app/shared/models/job_listing_metadata.dart';
import 'package:my_app/shared/models/listing_model.dart';
import 'package:my_app/shared/models/tutoring_listing_metadata.dart';

void main() {
  group('buildListingMetadataDisplay', () {
    test('builds tutoring rows and stage chips', () {
      final display = buildListingMetadataDisplay(
        ListingModel(
          id: '1',
          userId: 'u',
          categoryId: 1,
          titleAr: 'دروس رياضيات',
          descriptionAr: 'ignored',
          price: 15000,
          city: 'بغداد',
          governorate: 'baghdad',
          displayStatus: ListingDisplayStatus.active,
          createdAt: DateTime(2026),
          metadata: const TutoringListingMetadata(
            subject: 'رياضيات',
            curriculum: 'المنهج العراقي',
            stages: ['إعدادي', 'جامعي'],
            sessionType: 'أونلاين',
            pricePerHour: 15000,
          ).toJson(),
        ),
      );

      expect(display.rows.any((r) => r.key == 'المادة' && r.value == 'رياضيات'),
          isTrue);
      expect(display.chipGroups.single.chips, ['إعدادي', 'جامعي']);
    });

    test('builds job rows and benefit chips', () {
      final display = buildListingMetadataDisplay(
        ListingModel(
          id: '1',
          userId: 'u',
          categoryId: 1,
          titleAr: 'وظيفة',
          descriptionAr: 'ignored',
          price: 500000,
          city: 'بغداد',
          governorate: 'baghdad',
          displayStatus: ListingDisplayStatus.active,
          createdAt: DateTime(2026),
          metadata: const JobListingMetadata(
            jobType: 'دوام كامل',
            sector: 'تقنية',
            salaryMin: 500000,
            benefits: ['سكن'],
          ).toJson(),
        ),
      );

      expect(display.rows.any((r) => r.key == 'نوع الدوام'), isTrue);
      expect(display.chipGroups.single.chips, ['سكن']);
    });
  });
}
