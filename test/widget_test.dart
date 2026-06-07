import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/core/constants/app_constants.dart';
import 'package:my_app/core/utils/currency_formatter.dart';
import 'package:my_app/core/utils/digit_input_formatter.dart';
import 'package:my_app/core/utils/validators.dart';

void main() {
  test('formatIqd formats without decimals', () {
    expect(formatIqd(1500000), contains('د.ع'));
    expect(formatIqd(0), isNotEmpty);
  });

  test('Validators.iraqiPhone accepts local format', () {
    expect(Validators.iraqiPhone('7901234567'), isNull);
    expect(Validators.iraqiPhone('123'), isNotNull);
  });

  test('WesternDigitsInputFormatter converts Arabic numerals', () {
    expect(
      WesternDigitsInputFormatter.toWestern('٧٩٠١٢٣٤٥٦٧'),
      '7901234567',
    );
    expect(
      WesternDigitsInputFormatter.toWestern('7901234567'),
      '7901234567',
    );
  });

  test('Validators.normalizeLocalDigits strips Iraqi leading zero', () {
    expect(Validators.normalizeLocalDigits('07901234567', 'IQ'), '7901234567');
    expect(Validators.normalizeLocalDigits('9647901234567', 'IQ'), '7901234567');
  });

  test('Validators.toE164 adds country code', () {
    expect(Validators.toE164('7901234567'), '+9647901234567');
  });

  test('Validators.parsePrice handles commas', () {
    expect(Validators.parsePrice('1,500,000'), 1500000);
  });

  test('AppConstants has Arabic name', () {
    expect(AppConstants.appNameAr, 'سوق العراق');
    expect(AppConstants.bundleId, 'com.iraq.marketplace.souqiq');
  });
}
