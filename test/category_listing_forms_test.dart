import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/utils/animal_listing_utils.dart';
import 'package:my_app/core/utils/home_service_listing_utils.dart';
import 'package:my_app/core/utils/job_listing_utils.dart';
import 'package:my_app/core/utils/tutoring_listing_utils.dart';
import 'package:my_app/features/listings/providers/post_listing_provider.dart';
import 'package:my_app/shared/models/animal_listing_metadata.dart';
import 'package:my_app/shared/models/category_model.dart';
import 'package:my_app/shared/models/home_service_listing_metadata.dart';
import 'package:my_app/shared/models/job_listing_metadata.dart';
import 'package:my_app/shared/models/tutoring_listing_metadata.dart';

void main() {
  group('category path detection', () {
    test('tutoring root', () {
      expect(
        isTutoringCategoryPath(const [
          CategoryModel(
            id: 1,
            slug: 'tutoring',
            nameAr: 'دروس خصوصية',
            icon: 'category',
          ),
        ]),
        isTrue,
      );
    });

    test('jobs root', () {
      expect(
        isJobCategoryPath(const [
          CategoryModel(
            id: 1,
            slug: 'jobs',
            nameAr: 'فرص العمل',
            icon: 'category',
          ),
        ]),
        isTrue,
      );
    });

    test('pets root', () {
      expect(
        isAnimalCategoryPath(const [
          CategoryModel(
            id: 1,
            slug: 'pets',
            nameAr: 'الحيوانات',
            icon: 'category',
          ),
        ]),
        isTrue,
      );
    });
  });

  group('metadata serialization', () {
    test('tutoring metadata json', () {
      const details = TutoringListingMetadata(
        subject: 'رياضيات',
        curriculum: 'المنهج العراقي',
        stages: ['إعدادي', 'جامعي'],
        sessionType: 'أونلاين',
        pricePerHour: 15000,
        experienceYears: 5,
        qualifications: 'بكالوريوس',
      );
      final json = details.toJson();
      expect(json['listing_kind'], 'tutoring');
      expect(json['subject'], 'رياضيات');
      expect(json['stages'], ['إعدادي', 'جامعي']);
      expect(json['price_per_hour'], '15000');
    });

    test('job metadata json', () {
      const details = JobListingMetadata(
        jobType: 'دوام كامل',
        sector: 'تقنية المعلومات والبرمجة',
        salaryMin: 500000,
        salaryMax: 1000000,
        benefits: ['سكن', 'تأمين صحي'],
      );
      final json = details.toJson();
      expect(json['listing_kind'], 'job');
      expect(json['benefits'], ['سكن', 'تأمين صحي']);
    });

    test('animal metadata json', () {
      const details = AnimalListingMetadata(
        animalType: 'كلب',
        breed: 'جيرمن شيبرد',
        ageMonths: 6,
        gender: 'ذكر',
        vaccinated: true,
      );
      final json = details.toJson();
      expect(json['listing_kind'], 'animal');
      expect(json['vaccinated'], isTrue);
    });

    test('deriveAnimalDetailsFromPath reads type and breed from breadcrumb', () {
      final details = deriveAnimalDetailsFromPath(const [
        CategoryModel(
          id: 1,
          slug: 'pets',
          nameAr: 'الحيوانات',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'pets_dogs',
          nameAr: 'كلب',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'german_shepherd',
          nameAr: 'جيرمن شيبرد',
          icon: 'model',
          parentId: 2,
        ),
      ]);

      expect(details.animalType, 'كلب');
      expect(details.breed, 'جيرمن شيبرد');
    });

    test('animalDetailsForStorage uses breadcrumb type and breed', () {
      const path = [
        CategoryModel(
          id: 1,
          slug: 'pets',
          nameAr: 'الحيوانات',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'pets_cats',
          nameAr: 'قطة',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'persian',
          nameAr: 'شيرازي',
          icon: 'model',
          parentId: 2,
        ),
      ];

      const userDetails = AnimalListingMetadata(
        animalType: 'ignored',
        breed: 'ignored',
        gender: 'أنثى',
      );

      final stored = animalDetailsForStorage(path, userDetails);

      expect(stored.animalType, 'قطة');
      expect(stored.breed, 'شيرازي');
      expect(stored.gender, 'أنثى');
    });

    test('homeServiceDetailsForStorage uses breadcrumb service type', () {
      const path = [
        CategoryModel(
          id: 1,
          slug: 'home_help',
          nameAr: 'مساعدة منزلية',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'home_cleaning',
          nameAr: 'تنظيف',
          icon: 'category',
          parentId: 1,
        ),
      ];

      const userDetails = HomeServiceListingMetadata(
        serviceType: 'ignored',
        availability: 'صباحي',
        salaryExpected: 400000,
      );

      final stored = homeServiceDetailsForStorage(path, userDetails);

      expect(stored.serviceType, 'تنظيف');
      expect(stored.availability, 'صباحي');
    });
  });

  group('PostListingNotifier validation', () {
    test('tutoring requires subject, stage, session, and hourly price', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(postListingProvider.notifier);

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'tutoring',
          nameAr: 'دروس خصوصية',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'tutor_school_math',
          nameAr: 'الرياضيات',
          icon: 'model',
          parentId: 1,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر المرحلة الدراسية');

      notifier.updateTutoringDetails(
        container.read(postListingProvider).tutoringDetails.copyWith(
              stages: ['إعدادي'],
              sessionType: 'أونلاين',
              pricePerHour: 15000,
            ),
      );
      expect(notifier.validateStep(2), isNull);
    });

    test('job requires job type, sector, and salary min', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(postListingProvider.notifier);

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'jobs',
          nameAr: 'فرص العمل',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'jobs_it',
          nameAr: 'تقنية المعلومات',
          icon: 'category',
          parentId: 1,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر نوع الدوام');

      notifier.updateJobDetails(
        const JobListingMetadata(
          jobType: 'دوام كامل',
          sector: 'تقنية المعلومات والبرمجة',
          salaryMin: 500000,
        ),
      );
      expect(notifier.validateStep(2), isNull);
    });

    test('animal requires category type and price, not form type selector', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(postListingProvider.notifier);

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'pets',
          nameAr: 'الحيوانات',
          icon: 'category',
        ),
      ]);
      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر نوع الحيوان من الفئات');

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'pets',
          nameAr: 'الحيوانات',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'pets_dogs',
          nameAr: 'كلب',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'german_shepherd',
          nameAr: 'جيرمن شيبرد',
          icon: 'model',
          parentId: 2,
        ),
      ]);
      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'أدخل سعراً صالحاً');

      notifier.updateField('price', 250000.0);
      expect(notifier.validateStep(2), isNull);
    });

    test('home service requires category service type and salary', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(postListingProvider.notifier);

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'home_help',
          nameAr: 'مساعدة منزلية',
          icon: 'category',
        ),
      ]);
      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر نوع الخدمة من الفئات');

      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 1,
          slug: 'home_help',
          nameAr: 'مساعدة منزلية',
          icon: 'category',
        ),
        CategoryModel(
          id: 2,
          slug: 'home_cleaning',
          nameAr: 'تنظيف',
          icon: 'category',
          parentId: 1,
        ),
      ]);
      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر أوقات العمل');

      notifier.updateHomeServiceDetails(
        container.read(postListingProvider).homeServiceDetails.copyWith(
              availability: 'صباحي',
              salaryExpected: 500000,
            ),
      );
      expect(notifier.validateStep(2), isNull);
    });
  });
}
