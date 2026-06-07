import 'package:flutter/services.dart';

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
