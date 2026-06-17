import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/category_fallback_icon.dart';
import 'package:my_app/features/home/widgets/category_grid.dart';
import 'package:my_app/shared/models/category_model.dart';
import 'package:my_app/shared/widgets/category_icon.dart';

void main() {
  group('CategoryGrid placeholder helpers', () {
    test('isPackagePlaceholderIcon is true for generic category icon', () {
      expect(CategoryGrid.isPackagePlaceholderIcon('category'), isTrue);
      expect(CategoryGrid.isPackagePlaceholderIcon('home'), isFalse);
      expect(CategoryGrid.isPackagePlaceholderIcon('unknown_material_key'), isTrue);
    });
  });

  group('CategoryIcon', () {
    testWidgets('shows packet PNG for real-estate leaf categories', (tester) async {
      const category = CategoryModel(
        id: 10,
        slug: 're_residential_sale_apartment',
        nameAr: 'شقة',
        icon: 'category',
        parentId: 9,
        colorHex: '#FF9800',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryIcon(category: category),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        CategoryFallbackIcon.assetPath,
      );
      expect(find.text(CategoryGrid.packagePlaceholderEmoji), findsNothing);
    });

    testWidgets('keeps dedicated emoji icons unchanged', (tester) async {
      const category = CategoryModel(
        id: 2,
        slug: 're_custom_branch',
        nameAr: 'سكني',
        icon: '🏠',
        parentId: 1,
        colorHex: '#FF9800',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryIcon(category: category),
          ),
        ),
      );

      expect(find.text('🏠'), findsOneWidget);
      expect(find.byType(Image), findsNothing);
    });

    testWidgets('shows packet PNG for tutoring school subject leaves', (tester) async {
      const category = CategoryModel(
        id: 201,
        slug: 'tutor_school_physics',
        nameAr: 'الفيزياء',
        icon: 'model',
        parentId: 200,
        colorHex: '#4CAF50',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CategoryIcon(category: category),
          ),
        ),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.image, isA<AssetImage>());
      expect(
        (image.image as AssetImage).assetName,
        CategoryFallbackIcon.assetPath,
      );
      expect(find.text('ال'), findsNothing);
    });
  });
}
