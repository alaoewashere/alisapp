import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/features/listings/widgets/category_tree_row.dart';

void main() {
  testWidgets('CategoryAllListingsRow shows volt label and count', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CategoryAllListingsRow(
            categoryNameAr: 'العقارات',
            listingCount: 42,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.text('كل إعلانات العقارات'), findsOneWidget);
    expect(find.text('42'), findsOneWidget);
    expect(find.byIcon(Icons.list_alt_rounded), findsOneWidget);

    final label = tester.widget<Text>(find.text('كل إعلانات العقارات'));
    expect(label.style?.color, AppColors.volt);
  });
}
