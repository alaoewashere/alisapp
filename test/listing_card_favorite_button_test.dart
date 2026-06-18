import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/shared/widgets/listing_card_favorite_button.dart';

void main() {
  testWidgets('ListingCardFavoriteButton uses volt when saved', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingCardFavoriteButton(
            isFavorite: true,
            onTap: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.favorite));
    expect(icon.color, AppColors.volt);
  });

  testWidgets('ListingCardFavoriteButton uses white outline when not saved',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListingCardFavoriteButton(
            isFavorite: false,
            onTap: () {},
          ),
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byIcon(Icons.favorite_border));
    expect(icon.color, AppColors.pureWhite);
  });
}
