import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/utils/real_estate_listing_utils.dart';
import 'package:Sello/shared/models/category_model.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/real_estate_listing_metadata.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';

void main() {
  group('PostListingState category path', () {
    test('categoryPathLabel joins names with separator', () {
      const state = PostListingState(
        categoryPath: [
          CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
          CategoryModel(
            id: 2,
            slug: 'veh_auto',
            nameAr: 'سيارات',
            icon: 'category',
            parentId: 1,
          ),
          CategoryModel(
            id: 3,
            slug: 'toyota',
            nameAr: 'Toyota',
            icon: 'brand',
            parentId: 2,
          ),
        ],
        selectedCategory: CategoryModel(
          id: 3,
          slug: 'toyota',
          nameAr: 'Toyota',
          icon: 'brand',
          parentId: 2,
        ),
      );

      expect(state.categoryPathLabel, 'المركبات > سيارات > Toyota');
      expect(state.effectiveCategory?.nameAr, 'Toyota');
    });
  });

  group('PostListingNotifier category drill', () {
    test('selectLeafCategory stores full path and leaf', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const path = [
        CategoryModel(id: 1, slug: 'jobs', nameAr: 'فرص العمل', icon: 'category'),
        CategoryModel(
          id: 2,
          slug: 'jobs_it',
          nameAr: 'تقنية المعلومات',
          icon: 'category',
          parentId: 1,
        ),
        CategoryModel(
          id: 3,
          slug: 'jobs_web',
          nameAr: 'مطور ويب',
          icon: 'category',
          parentId: 2,
        ),
      ];

      notifier.selectLeafCategory(path);
      final state = container.read(postListingProvider);

      expect(state.categoryPath, path);
      expect(state.selectedCategory?.id, 3);
      expect(state.selectedSubcategory, isNull);
    });

    test('validateStep 1 requires leaf selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      expect(notifier.validateStep(1), 'اختر الفئة');

      notifier.selectLeafCategory(const [
        CategoryModel(id: 1, slug: 'x', nameAr: 'X', icon: 'category'),
      ]);
      expect(notifier.validateStep(1), isNull);
    });

    test('validateStep 2 vehicle requires fuel and transmission', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: 'category'),
        CategoryModel(
          id: 2,
          slug: 'veh_auto',
          nameAr: 'سيارات',
          icon: 'category',
          parentId: 1,
        ),
      ]);

      notifier.updateField('title', 'عنوان الإعلان');

      expect(notifier.validateStep(2), 'اختر الحالة');

      notifier.updateField('condition', ListingCondition.used);
      expect(notifier.validateStep(2), 'اختر نوع الوقود');

      notifier.updateVehicleDetails(
        const VehicleListingMetadata(fuel: 'بenzin'),
      );
      expect(notifier.validateStep(2), 'اختر ناقل الحركة');

      notifier.updateVehicleDetails(
        const VehicleListingMetadata(
          fuel: 'بenzin',
          transmission: 'أوتوماتيك',
        ),
      );
      notifier.updateField('price', 25000000.0);
      expect(notifier.validateStep(2), isNull);
    });

    test('resetCategoryDrill clears path and selection', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.selectLeafCategory(const [
        CategoryModel(id: 1, slug: 'x', nameAr: 'X', icon: 'category'),
      ]);
      notifier.resetCategoryDrill();

      final state = container.read(postListingProvider);
      expect(state.categoryPath, isEmpty);
      expect(state.categoryDrillStack, isEmpty);
      expect(state.selectedCategory, isNull);
    });

    test('popCategoryDrillLevel pops one drill level', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const root = CategoryModel(
        id: 1,
        slug: 'cars',
        nameAr: 'المركبات',
        icon: 'category',
      );
      const child = CategoryModel(
        id: 2,
        slug: 'veh_auto',
        nameAr: 'سيارات',
        icon: 'category',
        parentId: 1,
      );
      const brand = CategoryModel(
        id: 3,
        slug: 'mercedes',
        nameAr: 'Mercedes-Benz',
        icon: 'brand',
        parentId: 2,
      );
      const rootChildren = [child];
      const brandChildren = [brand];

      notifier.selectCategoryAtDrillDepth(0, root);
      notifier.pushCategoryDrillLevel(rootChildren);
      notifier.selectCategoryAtDrillDepth(1, child);
      notifier.pushCategoryDrillLevel(brandChildren);

      expect(container.read(postListingProvider).categoryPath, [root, child]);
      expect(container.read(postListingProvider).categoryDrillStack.length, 2);
      expect(container.read(postListingProvider).canPopCategoryDrill, isTrue);

      notifier.popCategoryDrillLevel();

      final state = container.read(postListingProvider);
      expect(state.categoryPath, [root]);
      expect(state.categoryDrillStack, [rootChildren]);
      expect(state.canPopCategoryDrill, isTrue);

      notifier.popCategoryDrillLevel();

      final rootState = container.read(postListingProvider);
      expect(rootState.categoryPath, isEmpty);
      expect(rootState.categoryDrillStack, isEmpty);
      expect(rootState.canPopCategoryDrill, isFalse);
    });

    test('jumpCategoryDrillToDepth trims path and stack', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const root = CategoryModel(
        id: 1,
        slug: 'cars',
        nameAr: 'المركبات',
        icon: 'category',
      );
      const child = CategoryModel(
        id: 2,
        slug: 'veh_auto',
        nameAr: 'سيارات',
        icon: 'category',
        parentId: 1,
      );
      const brand = CategoryModel(
        id: 3,
        slug: 'mercedes',
        nameAr: 'Mercedes-Benz',
        icon: 'brand',
        parentId: 2,
      );
      const rootChildren = [child];
      const brandChildren = [brand];
      const modelChildren = [
        CategoryModel(
          id: 4,
          slug: 'a_class',
          nameAr: 'A-Class',
          icon: 'model',
          parentId: 3,
        ),
      ];

      notifier.selectCategoryAtDrillDepth(0, root);
      notifier.pushCategoryDrillLevel(rootChildren);
      notifier.selectCategoryAtDrillDepth(1, child);
      notifier.pushCategoryDrillLevel(brandChildren);
      notifier.selectCategoryAtDrillDepth(2, brand);
      notifier.pushCategoryDrillLevel(modelChildren);

      notifier.jumpCategoryDrillToDepth(2);

      final state = container.read(postListingProvider);
      expect(state.categoryPath, [root, child]);
      expect(state.categoryDrillStack, [rootChildren, brandChildren]);
    });

    test('selectCategoryAtDrillDepth replaces root when switching categories', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      const realEstateRoot = CategoryModel(
        id: 1,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'category',
      );
      const residential = CategoryModel(
        id: 2,
        slug: 're_residential',
        nameAr: 'سكني',
        icon: 'category',
        parentId: 1,
      );
      const carsRoot = CategoryModel(
        id: 3,
        slug: 'cars',
        nameAr: 'المركبات',
        icon: 'category',
      );

      notifier.selectLeafCategory([realEstateRoot, residential]);
      notifier.updateRealEstateDetails(
        const RealEstateListingMetadata(
          propertyType: 'شقة',
          offerType: 'بيع',
          areaSqm: 120,
        ),
      );

      notifier.selectCategoryAtDrillDepth(0, carsRoot);

      final state = container.read(postListingProvider);
      expect(state.categoryPath, [carsRoot]);
      expect(state.isRealEstateListing, isFalse);
      expect(state.isVehicleListing, isTrue);
      expect(state.selectedCategory, isNull);
      expect(state.realEstateDetails.propertyType, isNull);
    });
  });
}
