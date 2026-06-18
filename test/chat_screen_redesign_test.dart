import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:Sello/features/chat/widgets/message_bubble.dart';
import 'package:Sello/shared/models/message_model.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ar');
  });

  final now = DateTime(2026, 6, 8, 14, 30);

  MessageModel message({
    required String id,
    required String senderId,
    String content = 'مرحباً',
    String? imageUrl,
    bool isRead = false,
  }) {
    return MessageModel(
      id: id,
      conversationId: 'conv-1',
      senderId: senderId,
      content: content,
      imageUrl: imageUrl,
      isRead: isRead,
      createdAt: now,
    );
  }

  group('MessageBubble', () {
    testWidgets('renders sent bubble with read receipt', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message(id: '1', senderId: 'me', isRead: true),
              currentUserId: 'me',
              isFirstInGroup: true,
              isLastInGroup: true,
            ),
          ),
        ),
      );

      expect(find.text('مرحباً'), findsOneWidget);
      expect(find.byIcon(Icons.done_all), findsOneWidget);
    });

    testWidgets('renders received bubble with avatar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message(id: '2', senderId: 'other'),
              currentUserId: 'me',
              isFirstInGroup: true,
              isLastInGroup: true,
              otherUserAvatarSeed: 'Felix',
            ),
          ),
        ),
      );

      expect(find.text('مرحباً'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
    });

    testWidgets('renders image when imageUrl is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: message(
                id: '3',
                senderId: 'me',
                content: 'صورة',
                imageUrl: 'https://example.com/photo.jpg',
              ),
              currentUserId: 'me',
              isFirstInGroup: true,
              isLastInGroup: true,
            ),
          ),
        ),
      );

      expect(find.text('صورة'), findsOneWidget);
    });
  });

  group('ChatDateSeparator', () {
    testWidgets('renders date label', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatDateSeparator(date: DateTime.now()),
          ),
        ),
      );

      expect(find.text('اليوم'), findsOneWidget);
    });
  });
}
