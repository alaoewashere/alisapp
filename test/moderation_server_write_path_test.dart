import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/moderation/content_moderation_service.dart';

/// Documents the server/client moderation contract:
/// client may preview censor UX, but must submit ORIGINAL text so Postgres
/// triggers can detect violations and persist counts.
void main() {
  test('censored payload no longer matches blocked words (server blind spot)', () {
    const service = ContentModerationService();
    const words = ['testbadword1'];

    final original = service.moderate(
      text: 'hello testbadword1',
      userId: 'u1',
      violationCount: 0,
      blockedNormalizedWords: words,
    );
    expect(original.hadViolation, isTrue);

    final alreadyCensored = service.moderate(
      text: original.censoredText,
      userId: 'u1',
      violationCount: 0,
      blockedNormalizedWords: words,
    );
    expect(alreadyCensored.hadViolation, isFalse);
  });
}
