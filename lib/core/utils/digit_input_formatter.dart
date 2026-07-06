import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

/// Accepts Western (0-9), Eastern Arabic (٠-٩), and Persian (۰-۹) numerals.
class WesternDigitsInputFormatter extends TextInputFormatter {
  WesternDigitsInputFormatter({this.maxLength});

  final int? maxLength;

  static const _easternArabic = '٠١٢٣٤٥٦٧٨٩';
  static const _persianArabic = '۰۱۲۳۴۵۶۷۸۹';

  static String toWestern(String input) {
    final buffer = StringBuffer();
    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final easternIndex = _easternArabic.indexOf(char);
      if (easternIndex >= 0) {
        buffer.write(easternIndex);
        continue;
      }
      final persianIndex = _persianArabic.indexOf(char);
      if (persianIndex >= 0) {
        buffer.write(persianIndex);
        continue;
      }
      if (RegExp(r'[0-9]').hasMatch(char)) {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = toWestern(newValue.text);
    if (maxLength != null && digits.length > maxLength!) {
      digits = digits.substring(0, maxLength!);
    }

    if (digits == oldValue.text) return oldValue;

    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}

/// Standard numeric formatter for Iraqi RTL inputs — accepts Western (0-9),
/// Eastern Arabic (٠-٩), and Persian (۰-۹) digits.
WesternDigitsInputFormatter appDigitsOnly({int? maxLength}) =>
    WesternDigitsInputFormatter(maxLength: maxLength);

/// Live thousands-separator formatter for price fields — normalises any digits
/// to Western and shows "1,250,000" as the user types. Parsers must strip commas
/// (the post-listing flow already does `.replaceAll(',', '')`).
class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  ThousandsSeparatorInputFormatter({this.maxDigits = 12});

  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var digits = WesternDigitsInputFormatter.toWestern(newValue.text);
    if (digits.length > maxDigits) digits = digits.substring(0, maxDigits);
    if (digits.isEmpty) return const TextEditingValue(text: '');

    final number = int.tryParse(digits);
    if (number == null) return oldValue;

    final formatted = NumberFormat('#,###', 'en_US').format(number);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

ThousandsSeparatorInputFormatter appThousands({int maxDigits = 12}) =>
    ThousandsSeparatorInputFormatter(maxDigits: maxDigits);
