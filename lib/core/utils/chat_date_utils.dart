import 'package:intl/intl.dart';

import '../constants/display_locale.dart';
import 'arabic_number.dart';

/// Arabic date separator for chat message groups.
String formatChatDateSeparator(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDay == today) return 'اليوم';
  if (messageDay == today.subtract(const Duration(days: 1))) return 'أمس';
  return DateFormat('EEEE d MMMM yyyy', DisplayLocale.intlWesternArabic)
      .format(dateTime);
}

bool isSameChatDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatMessageTime(DateTime dateTime) {
  return DateFormat('HH:mm', DisplayLocale.intlWesternArabic).format(dateTime);
}

/// Relative time for conversation list — Arabic-Indic numerals, natural phrasing.
String formatConversationTimeAr(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'الآن';

  if (diff.inMinutes < 60) {
    if (diff.inMinutes == 1) return 'دقيقة واحدة';
    if (diff.inMinutes == 2) return 'دقيقتان';
    return '${arabicNumber(diff.inMinutes)} دقيقة';
  }

  if (diff.inHours < 24) {
    if (diff.inHours == 1) return 'ساعة واحدة';
    if (diff.inHours == 2) return 'ساعتان';
    return '${arabicNumber(diff.inHours)} ساعة';
  }

  if (diff.inDays == 1) return 'أمس';
  if (diff.inDays < 7) {
    if (diff.inDays == 2) return 'يومان';
    return '${arabicNumber(diff.inDays)} أيام';
  }

  return DateFormat('d MMM', DisplayLocale.intlWesternArabic).format(dateTime);
}
