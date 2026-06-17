import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/listings/widgets/category_bento_grid.dart';
import 'package:my_app/shared/models/category_model.dart';

void main() {
  group('CategoryBentoGrid', () {
    final all = [
      const CategoryModel(
        id: 1,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'real_estate',
      ),
      const CategoryModel(
        id: 2,
        slug: 'residential',
        nameAr: 'سكني',
        icon: 'category',
        parentId: 1,
      ),
      const CategoryModel(
        id: 3,
        slug: 'commercial',
        nameAr: 'تجاري',
        icon: 'category',
        parentId: 1,
      ),
    ];

    testWidgets('renders 2-column grid with title and subtitle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: CategoryBentoGrid(
                categories: [all[0]],
                all: all,
                onTap: (_) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('العقارات'), findsOneWidget);
      expect(find.text('سكني ، تجاري'), findsOneWidget);
      expect(find.byType(GridView), findsOneWidget);
    });

    testWidgets('invokes onTap when card is pressed', (tester) async {
      CategoryModel? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBentoGrid(
              categories: [all[0]],
              all: all,
              onTap: (c) => tapped = c,
            ),
          ),
        ),
      );

      await tester.tap(find.text('العقارات'));
      await tester.pumpAndSettle();

      expect(tapped?.id, 1);
    });
    testWidgets('shows vehicle asset icon for المركبات subcategory', (tester) async {
      const vehicleCategories = [
        CategoryModel(
          id: 1,
          slug: 'cars',
          nameAr: 'المركبات',
          icon: 'directions_car',
        ),
        CategoryModel(
          id: 2,
          slug: 'veh_automobile',
          nameAr: 'سيارات',
          icon: '🚗',
          parentId: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBentoGrid(
              categories: [vehicleCategories[1]],
              all: vehicleCategories,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('سيارات'), findsOneWidget);
    });
    testWidgets('shows real-estate asset icon for سكني subcategory', (tester) async {
      const realEstateCategories = [
        CategoryModel(
          id: 1,
          slug: 'real_estate',
          nameAr: 'العقارات',
          icon: 'home',
        ),
        CategoryModel(
          id: 2,
          slug: 're_residential',
          nameAr: 'سكني',
          icon: '🏠',
          parentId: 1,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CategoryBentoGrid(
              categories: [realEstateCategories[1]],
              all: realEstateCategories,
              onTap: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      expect(find.text('سكني'), findsOneWidget);
    });
  });
}
