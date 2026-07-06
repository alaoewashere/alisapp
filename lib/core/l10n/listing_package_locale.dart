import '../../features/listings/constants/listing_package_config.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/models/listing_model.dart';
import 'enum_localizations.dart';

class LocalizedPackageFeature {
  const LocalizedPackageFeature({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

String localizedPackageDuration(ListingPackage package, AppLocalizations l10n) {
  final days = switch (package) {
    ListingPackage.standard => 30,
    ListingPackage.pro => 60,
    ListingPackage.premium => 90,
  };
  return l10n.packageDurationDays(days);
}

List<LocalizedPackageFeature> localizedPackageFeatures(
  ListingPackage package,
  AppLocalizations l10n,
) {
  return switch (package) {
    ListingPackage.standard => [
      LocalizedPackageFeature(
        title: l10n.pkgStandardFeature1Title,
        description: l10n.pkgStandardFeature1Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgStandardFeature2Title,
        description: l10n.pkgStandardFeature2Desc,
      ),
    ],
    // Kept short and punchy on purpose — 4-5 features max so Pro/Premium
    // read as an obviously better deal, not a wall of text.
    ListingPackage.pro => [
      LocalizedPackageFeature(
        title: l10n.pkgProFeature1Title,
        description: l10n.pkgProFeature1Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgProFeature2Title,
        description: l10n.pkgProFeature2Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgProFeature4Title,
        description: l10n.pkgProFeature4Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgProFeature5Title,
        description: l10n.pkgProFeature5Desc,
      ),
    ],
    ListingPackage.premium => [
      LocalizedPackageFeature(
        title: l10n.pkgPremiumFeature1Title,
        description: l10n.pkgPremiumFeature1Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgPremiumFeature2Title,
        description: l10n.pkgPremiumFeature2Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgPremiumFeature4Title,
        description: l10n.pkgPremiumFeature4Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgPremiumFeature5Title,
        description: l10n.pkgPremiumFeature5Desc,
      ),
      LocalizedPackageFeature(
        title: l10n.pkgPremiumFeature6Title,
        description: l10n.pkgPremiumFeature6Desc,
      ),
    ],
  };
}

/// Resolves package tier copy for the post-listing package step.
class LocalizedListingPackageOption {
  const LocalizedListingPackageOption({
    required this.option,
    required this.label,
    required this.durationLabel,
    required this.features,
  });

  final ListingPackageOption option;
  final String label;
  final String durationLabel;
  final List<LocalizedPackageFeature> features;

  factory LocalizedListingPackageOption.fromConfig(
    ListingPackageOption option,
    AppLocalizations l10n,
  ) {
    return LocalizedListingPackageOption(
      option: option,
      label: option.package.localizedLabel(l10n),
      durationLabel: localizedPackageDuration(option.package, l10n),
      features: localizedPackageFeatures(option.package, l10n),
    );
  }
}
