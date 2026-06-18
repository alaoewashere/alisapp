import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/moderation/content_moderation_service.dart';
import 'package:Sello/core/utils/arabic_text_normalizer.dart';

void main() {
  const service = ContentModerationService();
  const blocked = ['testbadword1', 'testbadword2'];

  group('normalizeArabicForModeration', () {
    test('strips spaces between letters for matching', () {
      expect(
        normalizeArabicForModeration('te st bad word1'),
        'testbadword1',
      );
    });

    test('collapses 3+ repeated letters', () {
      expect(
        normalizeArabicForModeration('testbaaaadword1'),
        'testbaadword1',
      );
    });

    test('normalizes alef variants', () {
      expect(
        normalizeArabicForModeration('أإآtest'),
        'ااtest',
      );
    });
  });

  group('censorBlockedWords', () {
    test('replaces matched word with asterisks', () {
      final out = censorBlockedWords('hello testbadword1 world', blocked);
      expect(out, contains('***'));
      expect(out, isNot(contains('testbadword1')));
    });
  });

  group('ContentModerationService', () {
    test('first violation censors and allows', () {
      final result = service.moderate(
        text: 'hello testbadword1',
        userId: 'u1',
        violationCount: 0,
        blockedNormalizedWords: blocked,
      );
      expect(result.hadViolation, isTrue);
      expect(result.shouldBlock, isFalse);
      expect(result.censoredText, isNot(contains('testbadword1')));
    });

    test('second violation blocks', () {
      final result = service.moderate(
        text: 'hello testbadword1',
        userId: 'u1',
        violationCount: 1,
        blockedNormalizedWords: blocked,
      );
      expect(result.hadViolation, isTrue);
      expect(result.shouldBlock, isTrue);
      expect(result.censoredText, 'hello testbadword1');
    });

    test('clean text passes through', () {
      final result = service.moderate(
        text: 'مرحبا بالجميع',
        userId: 'u1',
        violationCount: 0,
        blockedNormalizedWords: blocked,
      );
      expect(result.hadViolation, isFalse);
      expect(result.shouldBlock, isFalse);
    });
  });
}
