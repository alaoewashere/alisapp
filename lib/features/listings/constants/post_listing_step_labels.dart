import '../../../l10n/app_localizations.dart';

/// App bar titles for the post-listing wizard steps.
String postListingStepAppBarTitle(AppLocalizations l10n, int step) {
  return switch (step) {
    1 => l10n.postListingStep1,
    2 => l10n.postListingStep2,
    3 => l10n.postListingStep3,
    4 => l10n.postListingStep4,
    5 => l10n.postListingStep5,
    6 => l10n.postListingStep6,
    7 => l10n.postListingStep7,
    8 => l10n.postListingStep8,
    _ => l10n.postListingStepFallback(step.toString()),
  };
}
