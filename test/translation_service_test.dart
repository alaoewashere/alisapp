import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/services/translation_service.dart';

void main() {
  tearDown(TranslationService.clearCacheForTesting);

  test('returns original text for Arabic target', () async {
    const text = 'سيارة للبيع';
    final result = await TranslationService.translate(text, 'ar');
    expect(result, text);
  });

  test('returns original text when empty', () async {
    final result = await TranslationService.translate('   ', 'en');
    expect(result, '   ');
  });

  test('clearCache clears translation cache', () async {
    TranslationService.clearCache();
    const text = 'cache probe';
    final first = await TranslationService.translate(text, 'en');
    TranslationService.clearCache();
    final second = await TranslationService.translate(text, 'en');
    expect(second, first);
  });
}
