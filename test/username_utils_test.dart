import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/username_utils.dart';

void main() {
  group('username validation', () {
    test('accepts valid usernames', () {
      expect(isValidUsernameFormat('ali'), isTrue);
      expect(isValidUsernameFormat('user_123'), isTrue);
      expect(isValidUsernameFormat('a' * 20), isTrue);
    });

    test('rejects invalid usernames', () {
      expect(isValidUsernameFormat('ab'), isFalse);
      expect(isValidUsernameFormat('a' * 21), isFalse);
      expect(isValidUsernameFormat('bad name'), isFalse);
      expect(isValidUsernameFormat('UPPER'), isFalse);
    });

    test('normalizeUsername lowercases', () {
      expect(normalizeUsername('Ali_1'), 'ali_1');
    });
  });
}
