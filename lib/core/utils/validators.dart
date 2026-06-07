class Validators {
  Validators._();

  static String? iraqiPhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل رقم الهاتف';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    // 10 digits starting with 7 (e.g. 7901234567)
    if (digits.length == 10 && digits.startsWith('7')) {
      return null;
    }
    // 13 digits with country code 964
    if (digits.length == 13 && digits.startsWith('9647')) {
      return null;
    }
    return 'رقم هاتف عراقي غير صالح';
  }

  static String toE164(String localPhone, {String dialCode = '+964'}) {
    final trimmed = localPhone.trim();
    if (trimmed.startsWith('+')) return trimmed;
    return formatE164(dialCode, localPhone);
  }

  /// Builds E.164 from dial code (+964) and local digits only.
  static String formatE164(String dialCode, String localDigits) {
    final dial = dialCode.replaceAll('+', '').replaceAll(RegExp(r'\D'), '');
    final local = localDigits.replaceAll(RegExp(r'\D'), '');
    return '+$dial$local';
  }

  static String normalizeE164(String phone) {
    final trimmed = phone.trim();
    if (trimmed.startsWith('+')) {
      return '+${trimmed.substring(1).replaceAll(RegExp(r'\D'), '')}';
    }
    return '+${trimmed.replaceAll(RegExp(r'\D'), '')}';
  }

  /// Strips country prefix and leading zero for local entry (e.g. 0790… → 790…).
  static String normalizeLocalDigits(String input, String isoCountryCode) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (isoCountryCode == 'IQ') {
      if (digits.startsWith('964')) {
        digits = digits.substring(3);
      }
      while (digits.startsWith('0') && digits.length > 1) {
        digits = digits.substring(1);
      }
    }
    return digits;
  }

  /// Validates local digits for the selected ISO country code.
  static String? localPhone(String? localDigits, String isoCountryCode) {
    if (localDigits == null || localDigits.trim().isEmpty) {
      return 'أدخل رقم الهاتف';
    }
    final digits = normalizeLocalDigits(localDigits, isoCountryCode);
    final min = minLocalDigits(isoCountryCode);
    final max = maxLocalDigits(isoCountryCode);

    if (digits.length < min || digits.length > max) {
      return 'رقم الهاتف غير صالح';
    }

    if (isoCountryCode == 'IQ' && !digits.startsWith('7')) {
      return 'رقم هاتف عراقي غير صالح';
    }

    return null;
  }

  static int minLocalDigits(String isoCountryCode) {
    return switch (isoCountryCode) {
      'IQ' => 10,
      'US' || 'CA' => 10,
      _ => 8,
    };
  }

  static int maxLocalDigits(String isoCountryCode) {
    return switch (isoCountryCode) {
      'IQ' => 10,
      'US' || 'CA' => 10,
      _ => 15,
    };
  }

  static String? otp(String? value) {
    if (value == null || value.trim().length != 6) {
      return 'أدخل رمز التحقق المكون من 6 أرقام';
    }
    return null;
  }

  static String? requiredField(String? value, {String label = 'هذا الحقل'}) {
    if (value == null || value.trim().isEmpty) {
      return '$label مطلوب';
    }
    return null;
  }

  static String? price(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'أدخل السعر';
    }
    final parsed = int.tryParse(value.replaceAll(',', '').replaceAll(' ', ''));
    if (parsed == null || parsed < 0) {
      return 'سعر غير صالح';
    }
    return null;
  }

  static int parsePrice(String value) {
    return int.parse(value.replaceAll(',', '').replaceAll(' ', ''));
  }
}
