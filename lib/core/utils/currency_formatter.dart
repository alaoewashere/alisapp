import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../constants/display_locale.dart';

/// Formats IQD with Western numerals and a currency suffix (default Arabic د.ع).
String formatIQD(double amount, {String currencySuffix = 'د.ع'}) {
  final formatter = NumberFormat('#,###', 'en_US');
  return '${formatter.format(amount.round())} $currencySuffix';
}

/// Approximate IQD → USD rate (Iraqi market). Adjust here if it shifts.
const double kApproxIqdPerUsd = 1320.0;

/// Compact "≈ $X" USD estimate for an IQD amount. Empty for non-positive input.
String formatUsdApprox(double iqd) {
  if (iqd <= 0) return '';
  final usd = iqd / kApproxIqdPerUsd;
  if (usd < 1) return '≈ \$${usd.toStringAsFixed(2)}';
  final formatter = NumberFormat('#,###', 'en_US');
  return '≈ \$${formatter.format(usd.round())}';
}

/// Locale-aware IQD formatting using [AppLocalizations.currencyIqd].
String formatIQDWithL10n(double amount, AppLocalizations l10n) =>
    formatIQD(amount, currencySuffix: l10n.currencyIqd);

/// Formats IQD from integer amount (backward compatible).
String formatIqd(int amount, {String currencySuffix = 'د.ع'}) =>
    formatIQD(amount.toDouble(), currencySuffix: currencySuffix);

String formatIqdWithL10n(int amount, AppLocalizations l10n) =>
    formatIqd(amount, currencySuffix: l10n.currencyIqd);

/// Package tier price label with currency prefix and Western numerals.
String formatPackagePriceIqd(int amount, {String currencySuffix = 'د.ع'}) {
  final formatter = NumberFormat('#,###', 'en_US');
  return '$currencySuffix ${formatter.format(amount)}';
}

String formatPackagePriceWithL10n(int amount, AppLocalizations l10n) =>
    formatPackagePriceIqd(amount, currencySuffix: l10n.currencyIqd);

String formatRelativeTimeAr(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
  if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
  return DateFormat('d MMM yyyy', DisplayLocale.intlWesternArabic).format(dateTime);
}
