import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/listings/providers/post_listing_provider.dart';
import 'package:my_app/shared/models/category_model.dart';
import 'package:my_app/shared/models/real_estate_listing_metadata.dart';

void main() {
  group('Step 2 title and description validation', () {
    test('validateStep requires title with at least 5 characters on step 2', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);

      expect(notifier.validateStep(2), 'العنوان يجب أن يكون 5 أحرف على الأقل');

      notifier.updateField('title', 'abcd');
      expect(notifier.validateStep(2), 'العنوان يجب أن يكون 5 أحرف على الأقل');

      notifier.updateField('title', 'عنوان الإعلان');
      expect(
        notifier.validateStep(2),
        isNot('العنوان يجب أن يكون 5 أحرف على الأقل'),
      );
    });

    test('description is optional on step 2', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.updateField('title', 'عنوان الإعلان');
      notifier.updateField('description', '');

      expect(notifier.validateStep(2), isNot(contains('وصف')));
    });

    test('syncRealEstateListingCopy keeps user-written description', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const realEstateRoot = CategoryModel(
        id: 10,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'category',
      );
      const residential = CategoryModel(
        id: 11,
        slug: 'residential',
        nameAr: 'سكني',
        icon: 'category',
        parentId: 10,
      );

      notifier.selectLeafCategory([realEstateRoot, residential]);
      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'شقة',
          offerType: 'بيع',
          areaSqm: 90,
        ),
      );
      notifier.updateField('description', 'وصف مخصص من المستخدم');

      notifier.syncRealEstateListingCopy();

      expect(
        container.read(postListingProvider).description,
        'وصف مخصص من المستخدم',
      );
    });

    test('syncRealEstateListingCopy keeps user-written title', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const realEstateRoot = CategoryModel(
        id: 10,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'category',
      );
      const residential = CategoryModel(
        id: 11,
        slug: 'residential',
        nameAr: 'سكني',
        icon: 'category',
        parentId: 10,
      );

      notifier.selectLeafCategory([realEstateRoot, residential]);
      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'فيلا',
          offerType: 'بيع',
          areaSqm: 90000,
          rooms: '2',
        ),
      );
      notifier.updateField('title', 'فيلا فاخرة للبيع في المنصور');

      notifier.syncRealEstateListingCopy();

      expect(
        container.read(postListingProvider).title,
        'فيلا فاخرة للبيع في المنصور',
      );
    });

    test('selecting category does not pre-fill title field', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(
          id: 10,
          slug: 'real_estate',
          nameAr: 'العقارات',
          icon: 'category',
        ),
        CategoryModel(
          id: 11,
          slug: 'residential',
          nameAr: 'سكني',
          icon: 'category',
          parentId: 10,
        ),
      ]);
      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'شقة',
          offerType: 'بيع',
          areaSqm: 90,
          rooms: '2',
        ),
      );

      expect(container.read(postListingProvider).title, isEmpty);
    });
  });
}
