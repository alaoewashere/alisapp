import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/chat/widgets/listing_context_card.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      locale: const Locale('ar'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  group('ListingContextCard', () {
    testWidgets('shows listing title, price, and badge', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ListingContextCard(
            listingId: 'listing-1',
            title: 'سيارة تويota كامري 2020',
            price: 25000000,
          ),
        ),
      );

      expect(find.text('سيارة تويota كامري 2020'), findsOneWidget);
      expect(find.textContaining('25,000,000'), findsOneWidget);
      expect(find.text('إعلان'), findsOneWidget);
    });

    testWidgets('hides price when missing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ListingContextCard(
            listingId: 'listing-1',
            title: 'سيارة تويota كامري 2020',
          ),
        ),
      );

      expect(find.byType(ListingContextCard), findsOneWidget);
      expect(find.text('إعلان'), findsOneWidget);
    });

    testWidgets('shows placeholder when image is missing', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ListingContextCard(
            listingId: 'listing-1',
            title: 'سيارة تويota كامري 2020',
            imageUrl: null,
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
