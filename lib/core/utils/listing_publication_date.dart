import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../l10n/l10n_provider.dart';

/// Localized publication date (e.g. June 17, 2026 / 17 Haziran 2026).
String formatListingPublicationDate(DateTime date, Locale locale) {
  return DateFormat.yMMMMd(intlDisplayLocale(locale)).format(date);
}
