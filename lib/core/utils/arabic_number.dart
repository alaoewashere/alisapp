import 'package:intl/intl.dart';

/// Western digits (0–9) for all UI locales — use instead of Eastern Arabic numerals.
String arabicNumber(int n) => NumberFormat('#,###', 'en_US').format(n);

/// Compact count for profile stats (e.g. 1500 → 1.5 ألف).
String formatCompactArabic(int n) {
  if (n >= 1000000) {
    return '${_compactDecimal(n / 1000000)} مليون';
  }
  if (n >= 1000) {
    return '${_compactDecimal(n / 1000)} ألف';
  }
  return arabicNumber(n);
}

String _compactDecimal(double value) {
  if (value == value.roundToDouble()) {
    return value.round().toString();
  }
  return value.toStringAsFixed(1);
}
