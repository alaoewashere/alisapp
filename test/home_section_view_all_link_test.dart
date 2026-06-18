import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/features/home/widgets/home_section_view_all_link.dart';

void main() {
  testWidgets('HomeSectionViewAllLink matches categories view-all styling',
      (tester) async {
    var tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeSectionViewAllLink(onPressed: () => tapped = true),
        ),
      ),
    );

    final button = tester.widget<TextButton>(find.byType(TextButton));
    expect(button.style?.foregroundColor?.resolve({}), AppColors.accent);

    final label = tester.widget<Text>(find.text('عرض الكل'));
    expect(label.style?.fontSize, 11);
    expect(label.style?.fontWeight, FontWeight.w600);

    await tester.tap(find.text('عرض الكل'));
    await tester.pump();
    expect(tapped, isTrue);
  });

  test('home feed routes are guest-allowed', () {
    final routerSource =
        File('lib/core/router/app_router.dart').readAsStringSync();
    expect(routerSource, contains("path.startsWith('/feed/')"));
  });

  test('repository exposes paginated featured listings', () {
    final repoSource = File(
      'lib/features/listings/data/listings_repository.dart',
    ).readAsStringSync();
    expect(repoSource, contains('getFeaturedListingsPage'));
    expect(repoSource, contains('_featuredListingsBaseQuery'));
  });
}
