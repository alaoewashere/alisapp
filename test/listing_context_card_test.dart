import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/features/chat/widgets/listing_context_card.dart';
import 'package:my_app/shared/models/conversation_model.dart';

void main() {
  ConversationModel sampleConversation({
    String? listingTitle,
    String? listingImage,
    double? listingPrice,
  }) {
    return ConversationModel(
      id: 'conv-1',
      listingId: 'listing-1',
      buyerId: 'buyer-1',
      sellerId: 'seller-1',
      listingTitle: listingTitle ?? 'سيارة تويota كامري 2020',
      listingImage: listingImage,
      listingPrice: listingPrice ?? 25000000,
      otherUserName: 'أحمد',
      createdAt: DateTime(2026, 6, 8),
    );
  }

  group('ListingContextCard', () {
    testWidgets('shows listing title, price, and badge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingContextCard(
              conversation: sampleConversation(),
            ),
          ),
        ),
      );

      expect(find.text('سيارة تويota كامري 2020'), findsOneWidget);
      expect(find.textContaining('25,000,000'), findsOneWidget);
      expect(find.text('إعلان'), findsOneWidget);
    });

    testWidgets('hides when listing title is missing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingContextCard(
              conversation: sampleConversation(listingTitle: ''),
            ),
          ),
        ),
      );

      expect(find.byType(ListingContextCard), findsOneWidget);
      expect(find.text('إعلان'), findsNothing);
    });

    testWidgets('shows placeholder when image is missing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListingContextCard(
              conversation: sampleConversation(listingImage: null),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
    });
  });
}
