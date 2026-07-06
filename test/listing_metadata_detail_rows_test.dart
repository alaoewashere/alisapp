import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/listing_metadata_detail_rows.dart';
import 'package:Sello/l10n/app_localizations.dart';
import 'package:Sello/shared/models/job_listing_metadata.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/tutoring_listing_metadata.dart';

void main() {
  group('buildListingMetadataDisplay', () {
    test('builds tutoring rows and localized stage chips in English', () {
      final en = lookupAppLocalizations(const Locale('en'));
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
        en,
      );

      expect(
        display.rows.any((r) => r.key == 'المنهج' && r.value == 'Iraqi curriculum'),
        isTrue,
      );
      expect(display.chipGroups.single.chips, ['Secondary', 'University']);
    });

    test('builds job rows and localized benefit chips', () {
      final en = lookupAppLocalizations(const Locale('en'));
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
        en,
      );

      expect(
        display.rows.any((r) => r.key == 'نوع الدوام' && r.value == 'Full-time'),
        isTrue,
      );
      expect(display.chipGroups.single.chips, ['Housing']);
    });
  });
}
