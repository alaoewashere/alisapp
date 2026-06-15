import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/username_utils.dart';

void main() {
  group('normalizeUsername', () {
    test('trims and lowercases', () {
      expect(normalizeUsername('  MyUser_1  '), 'myuser_1');
    });
  });

  group('isValidUsernameLength', () {
    test('requires at least 3 characters', () {
      expect(isValidUsernameLength('ab'), isFalse);
      expect(isValidUsernameLength('abc'), isTrue);
    });
  });
}
