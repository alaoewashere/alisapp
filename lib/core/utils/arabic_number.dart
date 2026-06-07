const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

/// Formats [n] with Arabic-Indic digits (e.g. 125 → ١٢٥).
String arabicNumber(int n) {
  final s = n.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    final c = s[i];
    if (c.codeUnitAt(0) >= 48 && c.codeUnitAt(0) <= 57) {
      buffer.write(_arabicDigits[c.codeUnitAt(0) - 48]);
    } else {
      buffer.write(c);
    }
  }
  return buffer.toString();
}
