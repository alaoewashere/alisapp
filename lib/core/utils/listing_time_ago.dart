import 'package:timeago/timeago.dart' as timeago;

/// Maps app language codes to timeago locale ids.
String timeagoLocaleFor(String languageCode) {
  return switch (languageCode) {
    'en' => 'en',
    'tr' => 'tr',
    _ => 'ar',
  };
}

String formatListingTimeAgo(DateTime date, String languageCode) {
  return timeago.format(date, locale: timeagoLocaleFor(languageCode));
}
