import '../../l10n/app_localizations.dart';
import '../../shared/models/listing_model.dart';
import '../utils/listing_time_ago.dart';
import 'enum_localizations.dart';
import 'listing_attribute_locale.dart';

extension ListingModelDisplayL10n on ListingModel {
  String timeAgoFor(String languageCode) =>
      formatListingTimeAgo(createdAt, languageCode);

  String? conditionLabelFor(AppLocalizations l10n) =>
      condition?.localizedLabel(l10n);

  String categoryBreadcrumbFor(AppLocalizations l10n) {
    if (parentCategoryNameAr != null && categoryNameAr != null) {
      final parent = localizeListingAttribute(parentCategoryNameAr!, l10n);
      final leaf = localizeListingAttribute(categoryNameAr!, l10n);
      return '$parent > $leaf';
    }
    final name = categoryNameAr;
    if (name == null || name.isEmpty) return '';
    return localizeListingAttribute(name, l10n);
  }
}
