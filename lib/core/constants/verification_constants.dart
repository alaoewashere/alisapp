import '../../l10n/app_localizations.dart';

/// Profile verification status values stored in `profiles.verification_status`.
abstract final class VerificationStatus {
  static const unverified = 'unverified';
  static const pending = 'pending';
  static const verified = 'verified';
  static const rejected = 'rejected';
}

/// Document types for seller verification requests.
abstract final class VerificationDocumentType {
  static const nationalId = 'national_id';
  static const driversLicense = 'drivers_license';
  static const passport = 'passport';

  static const all = [nationalId, driversLicense, passport];

  static String localizedLabel(String type, AppLocalizations l10n) =>
      switch (type) {
        nationalId => l10n.nationalId,
        driversLicense => l10n.drivingLicense,
        passport => l10n.passport,
        _ => type,
      };

  static bool requiresBackImage(String type) =>
      type == nationalId || type == driversLicense;
}
