import '../../l10n/app_localizations.dart';
import '../../shared/models/listing_model.dart';
import '../../shared/models/vehicle_listing_metadata.dart';

extension ListingPackageL10n on ListingPackage {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingPackage.standard => l10n.packageStandardFull,
        ListingPackage.pro => l10n.packageProFull,
        ListingPackage.premium => l10n.packagePremiumFull,
      };

  String localizedBadge(AppLocalizations l10n) => switch (this) {
        ListingPackage.standard => l10n.packageFree,
        ListingPackage.pro => l10n.packagePro,
        ListingPackage.premium => l10n.packagePremium,
      };
}

extension ListingDisplayStatusL10n on ListingDisplayStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingDisplayStatus.active => l10n.statusActive,
        ListingDisplayStatus.pending => l10n.statusPending,
        ListingDisplayStatus.sold => l10n.statusSold,
        ListingDisplayStatus.deleted => l10n.statusDeleted,
      };
}

extension ListingModerationStatusL10n on ListingModerationStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingModerationStatus.pending => l10n.statusPending,
        ListingModerationStatus.approved => l10n.statusActive,
        ListingModerationStatus.rejected => l10n.statusRejected,
      };
}

extension ListingTypeL10n on ListingType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingType.sale => l10n.listingTypeSale,
        ListingType.rent => l10n.listingTypeRent,
      };
}

extension ListingContactPreferenceL10n on ListingContactPreference {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingContactPreference.phoneAndMessages =>
          l10n.contactPhoneAndMessages,
        ListingContactPreference.phoneOnly => l10n.contactPhoneOnly,
        ListingContactPreference.messagesOnly => l10n.contactMessagesOnly,
      };
}

extension ListingConditionL10n on ListingCondition {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        ListingCondition.newItem => l10n.conditionNew,
        ListingCondition.used => l10n.conditionUsed,
      };
}

extension SearchSortByL10n on SearchSortBy {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        SearchSortBy.newest => l10n.sortNewest,
        SearchSortBy.cheapest => l10n.sortCheapest,
        SearchSortBy.expensive => l10n.sortExpensive,
        SearchSortBy.mostViewed => l10n.sortMostViewed,
      };
}

extension FilterConditionL10n on FilterCondition {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        FilterCondition.all => l10n.all,
        FilterCondition.newItem => l10n.conditionNew,
        FilterCondition.used => l10n.conditionUsed,
      };
}

extension MileageUnitL10n on MileageUnit {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
        MileageUnit.km => l10n.statKm,
        MileageUnit.mile => l10n.statMile,
      };
}
