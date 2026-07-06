import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/models/category_model.dart';
import '../providers/locale_provider.dart';
import 'l10n_provider.dart';

/// Active language code for category / governorate display names.
final categoryLocaleCodeProvider = Provider<String>((ref) {
  return normalizeAppLocale(ref.watch(localeProvider)).languageCode;
});

extension CategoryModelLocale on CategoryModel {
  /// Localized display name from DB columns with Arabic fallback.
  String localizedName(String languageCode) => displayName(languageCode);

  /// Localized card / browse subtitle from DB description columns.
  String localizedDescription(String languageCode) =>
      displayDescription(languageCode);
}

extension CategoryListLocale on List<CategoryModel> {
  String joinedPathNames(String languageCode, {String separator = ' > '}) {
    return map((c) => c.localizedName(languageCode)).join(separator);
  }
}

/// Browse-grid title when Supabase row is missing or as override for top-level slugs.
String browseCategoryTitle(String slug, AppLocalizations strings) {
  return switch (slug) {
    'real_estate' => strings.categoryRealEstate,
    'cars' => strings.categoryVehicles,
    'electronics' => strings.categoryElectronics,
    'buy_sell' => strings.categoryBuySell,
    'tutoring' => strings.categoryTutoring,
    'jobs' => strings.categoryJobs,
    'pets' => strings.categoryPets,
    'home_help' => strings.categoryHomeHelp,
    _ => strings.categories,
  };
}

String browseCategorySubtitle(String slug, AppLocalizations strings) {
  return switch (slug) {
    'real_estate' => strings.categorySubtitleRealEstate,
    'cars' => strings.categorySubtitleVehicles,
    'electronics' => strings.categorySubtitleElectronics,
    'buy_sell' => strings.categorySubtitleBuySell,
    'tutoring' => strings.categorySubtitleTutoring,
    'jobs' => strings.categorySubtitleJobs,
    'pets' => strings.categorySubtitlePets,
    'home_help' => strings.categorySubtitleHomeHelp,
    _ => '',
  };
}
