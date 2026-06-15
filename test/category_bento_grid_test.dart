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
  });
}
