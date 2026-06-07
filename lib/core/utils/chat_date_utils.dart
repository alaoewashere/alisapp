import 'package:intl/intl.dart';

/// Arabic date separator for chat message groups.
String formatChatDateSeparator(DateTime dateTime) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final messageDay = DateTime(dateTime.year, dateTime.month, dateTime.day);

  if (messageDay == today) return 'اليوم';
  if (messageDay == today.subtract(const Duration(days: 1))) return 'أمس';
  return DateFormat('EEEE d MMMM yyyy', 'ar').format(dateTime);
}

bool isSameChatDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String formatMessageTime(DateTime dateTime) {
  return DateFormat('HH:mm', 'ar').format(dateTime);
}
