import '../../l10n/app_localizations.dart';
import '../utils/validators.dart';

/// Locale-aware form validators — use in auth and listing forms.
class ValidatorsL10n {
  ValidatorsL10n._();

  static String? iraqiPhone(String? value, AppLocalizations l10n) {
    final result = Validators.iraqiPhone(value);
    if (result == null) return null;
    if (result.contains('عراقي')) return l10n.validationPhoneInvalidIq;
    if (result.contains('أدخل')) return l10n.validationPhoneRequired;
    return l10n.validationPhoneInvalid;
  }

  static String? localPhone(
    String? localDigits,
    String isoCountryCode,
    AppLocalizations l10n,
  ) {
    final result = Validators.localPhone(localDigits, isoCountryCode);
    if (result == null) return null;
    if (result.contains('عراقي')) return l10n.validationPhoneInvalidIq;
    if (result.contains('أدخل')) return l10n.validationPhoneRequired;
    return l10n.validationPhoneInvalid;
  }

  static String? otp(String? value, AppLocalizations l10n) {
    if (Validators.otp(value) == null) return null;
    return l10n.validationOtpRequired;
  }

  static String? requiredField(String? value, AppLocalizations l10n,
      {String? fieldLabel}) {
    if (Validators.requiredField(value) == null) return null;
    return l10n.validationFieldRequired(fieldLabel ?? l10n.all);
  }

  static String? price(String? value, AppLocalizations l10n) {
    final result = Validators.price(value);
    if (result == null) return null;
    if (result.contains('أدخل')) return l10n.validationPriceRequired;
    return l10n.validationPriceInvalid;
  }

  static String? email(String? value, AppLocalizations l10n) {
    final result = Validators.email(value);
    if (result == null) return null;
    if (result.contains('أدخل')) return l10n.validationEmailRequired;
    return l10n.validationEmailInvalid;
  }

  static String? password(String? value, AppLocalizations l10n,
      {int minLength = 8}) {
    final result = Validators.password(value, minLength: minLength);
    if (result == null) return null;
    if (result.contains('أدخل')) return l10n.validationPasswordRequired;
    if (result.contains('أحرف')) {
      return l10n.validationPasswordMinLength(minLength);
    }
    return l10n.validationPasswordRequired;
  }

  static String? signUpPassword(String? value, AppLocalizations l10n,
      {int minLength = 8}) {
    final result = Validators.signUpPassword(value, minLength: minLength);
    if (result == null) return null;
    if (result.contains('صغير')) return l10n.validationPasswordLowercase;
    if (result.contains('كبير')) return l10n.validationPasswordUppercase;
    if (result.contains('رقماً')) return l10n.validationPasswordDigit;
    if (result.contains('رمزاً')) return l10n.validationPasswordSymbol;
    if (result.contains('8 أحرف') || result.contains('أحرف')) {
      return l10n.validationWeakPassword;
    }
    return password(value, l10n, minLength: minLength);
  }

  static String? confirmPassword(
    String? value,
    String password,
    AppLocalizations l10n,
  ) {
    final result = Validators.confirmPassword(value, password);
    if (result == null) return null;
    if (result.contains('أكّد')) return l10n.validationConfirmPasswordRequired;
    return l10n.validationPasswordMismatch;
  }
}
