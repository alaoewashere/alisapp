import 'package:intl/intl.dart';

/// Formats IQD with Western numerals and د.ع suffix.
String formatIQD(double amount) {
  final formatter = NumberFormat('#,###', 'en_US');
  return '${formatter.format(amount.round())} د.ع';
}

/// Formats IQD from integer amount (backward compatible).
String formatIqd(int amount) => formatIQD(amount.toDouble());

String formatRelativeTimeAr(DateTime dateTime) {
  final now = DateTime.now();
  final diff = now.difference(dateTime);

  if (diff.inMinutes < 1) return 'الآن';
  if (diff.inHours < 1) return 'منذ ${diff.inMinutes} د';
  if (diff.inDays < 1) return 'منذ ${diff.inHours} س';
  if (diff.inDays < 7) return 'منذ ${diff.inDays} ي';
  return DateFormat('d MMM yyyy', 'ar').format(dateTime);
}
