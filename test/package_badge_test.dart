import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/widgets/package_badge.dart';

void main() {
  group('ListingPackage.badgeLabelAr', () {
    test('returns short tier labels', () {
      expect(ListingPackage.standard.badgeLabelAr, 'مجاني');
      expect(ListingPackage.pro.badgeLabelAr, 'برو');
      expect(ListingPackage.premium.badgeLabelAr, 'مميز');
    });
  });

  group('PackageBadge.packageForListing', () {
    test('resolves premium and pro tiers', () {
      final premium = ListingModel(
        id: '1',
        userId: 'u',
        categoryId: 1,
        titleAr: 't',
        descriptionAr: '',
        price: 1,
        city: 'بغداد',
        governorate: 'baghdad',
        displayStatus: ListingDisplayStatus.active,
        createdAt: DateTime(2026, 1, 1),
        isFeatured: true,
      );
      final pro = premium.copyWith(isFeatured: false, isBoosted: true);
      final standard = premium.copyWith(isFeatured: false, isBoosted: false);

      expect(PackageBadge.packageForListing(premium), ListingPackage.premium);
      expect(PackageBadge.packageForListing(pro), ListingPackage.pro);
      expect(PackageBadge.packageForListing(standard), isNull);
    });
  });

  group('PackageBadge widget', () {
    testWidgets('renders premium star and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PackageBadge(package: ListingPackage.premium),
          ),
        ),
      );

      expect(find.text('مميز'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsOneWidget);
    });

    testWidgets('renders pro label without star by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PackageBadge(package: ListingPackage.pro),
          ),
        ),
      );

      expect(find.text('برو'), findsOneWidget);
      expect(find.byIcon(Icons.star_rounded), findsNothing);
    });

    testWidgets('renders free tier label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PackageBadge(package: ListingPackage.standard),
          ),
        ),
      );

      expect(find.text('مجاني'), findsOneWidget);
    });
  });
}
