import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/default_avatars.dart';
import 'package:my_app/core/utils/chat_date_utils.dart';
import 'package:my_app/features/chat/widgets/active_users_strip.dart';
import 'package:my_app/shared/models/conversation_model.dart';

void main() {
  group('formatConversationTimeAr', () {
    test('formats minutes with Arabic-Indic numerals', () {
      final time = DateTime.now().subtract(const Duration(minutes: 23));
      expect(formatConversationTimeAr(time), '23 دقيقة');
    });

    test('formats one hour naturally', () {
      final time = DateTime.now().subtract(const Duration(hours: 1));
      expect(formatConversationTimeAr(time), 'ساعة واحدة');
    });

    test('formats yesterday', () {
      final time = DateTime.now().subtract(const Duration(hours: 30));
      expect(formatConversationTimeAr(time), 'أمس');
    });
  });

  group('extractActiveChatUsers', () {
    final conversations = [
      ConversationModel(
        id: 'c1',
        listingId: 'l1',
        buyerId: 'me',
        sellerId: 'u1',
        otherUserName: 'أبو علي',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 10)),
        createdAt: DateTime.now(),
      ),
      ConversationModel(
        id: 'c2',
        listingId: 'l2',
        buyerId: 'u2',
        sellerId: 'me',
        otherUserName: 'فاطمة',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        createdAt: DateTime.now(),
      ),
    ];

    test('returns unique users in order', () {
      final users = extractActiveChatUsers(conversations, 'me');
      expect(users.length, 2);
      expect(users.first.name, 'أبو علي');
      expect(users.first.isOnline, isTrue);
    });

    test('counts recently active conversations', () {
      expect(countRecentlyActiveConversations(conversations), 2);
    });
  });

  group('defaultAvatars', () {
    test('finds preset by id', () {
      expect(defaultAvatarById('male_tech')?.emoji, '👨🏻‍💻');
      expect(defaultAvatarById('missing'), isNull);
    });
  });
}
