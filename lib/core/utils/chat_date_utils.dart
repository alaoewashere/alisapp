import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../constants/display_locale.dart';
import 'arabic_number.dart';

String _intlLocaleFor(String languageCode) {
  return switch (languageCode) {
    'en' => DisplayLocale.intlEnglish,
    'tr' => 'tr',
    _ => DisplayLocale.intlWesternArabic,
  };
}

/// Chat date separator — localized today/yesterday or formatted date.
String formatChatDateSeparator(
  DateTime dateTime,
  AppLocalizations strings, {
  String languageCode = 'ar',
}) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDay == today) return strings.today;
  if (messageDay == today.subtract(const Duration(days: 1))) {
    return strings.yesterday;
  }
  return DateFormat(
    'EEEE d MMMM yyyy',
    _intlLocaleFor(languageCode),
  ).format(dateTime);
}

bool isSameChatDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatMessageTime(DateTime dateTime, {String languageCode = 'ar'}) {
  return DateFormat('HH:mm', _intlLocaleFor(languageCode)).format(dateTime);
}

/// Relative time for conversation list.
String formatConversationTime(
  DateTime dateTime,
  AppLocalizations strings, {
  String languageCode = 'ar',
}) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);
  final useWesternDigits = languageCode != 'ar';

  String n(int value) =>
      useWesternDigits ? '$value' : arabicNumber(value);

  if (diff.inMinutes < 1) return strings.now;

  if (diff.inMinutes < 60) {
    if (diff.inMinutes == 1) return strings.oneMinuteAgo;
    if (diff.inMinutes == 2) return strings.twoMinutesAgo;
    return strings.minutesAgo(n(diff.inMinutes));
  }

  if (diff.inHours < 24) {
    if (diff.inHours == 1) return strings.oneHourAgo;
    if (diff.inHours == 2) return strings.twoHoursAgo;
    return strings.hoursAgo(n(diff.inHours));
  }

  if (diff.inDays == 1) return strings.yesterday;
  if (diff.inDays < 7) {
    if (diff.inDays == 2) return strings.twoDaysAgo;
    return strings.daysAgo(n(diff.inDays));
  }

  return DateFormat('d MMM', _intlLocaleFor(languageCode)).format(dateTime);
}
