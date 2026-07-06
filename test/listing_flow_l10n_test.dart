import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/l10n/enum_localizations.dart';
import 'package:Sello/core/l10n/listing_display_l10n.dart';
import 'package:Sello/core/l10n/listing_package_locale.dart';
import 'package:Sello/l10n/app_localizations.dart';
import 'package:Sello/shared/models/listing_model.dart';
import 'package:Sello/shared/models/vehicle_listing_metadata.dart';
import 'package:Sello/core/constants/verification_constants.dart';

void main() {
  test('contact and package labels localize in English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      ListingContactPreference.phoneAndMessages.localizedLabel(l10n),
      'Phone & messages',
    );
    expect(ListingPackage.standard.localizedLabel(l10n), 'Standard listing');
    expect(localizedPackageDuration(ListingPackage.standard, l10n), '30 days');
    expect(
      localizedPackageFeatures(ListingPackage.premium, l10n).first.title,
      'Featured carousel',
    );
  });

  test('listing breadcrumb and time ago respect English locale', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final listing = ListingModel(
      id: '1',
      userId: 'u1',
      categoryId: 1,
      titleAr: 'test',
      descriptionAr: 'test',
      price: 1000,
      city: 'baghdad',
      governorate: 'baghdad',
      displayStatus: ListingDisplayStatus.active,
      categoryNameAr: 'شقة',
      parentCategoryNameAr: 'عقارات',
      createdAt: DateTime.now().subtract(const Duration(seconds: 9)),
    );

    expect(listing.categoryBreadcrumbFor(l10n), contains('Apartment'));
    expect(listing.conditionLabelFor(l10n), isNull);
    expect(listing.timeAgoFor('en'), isNot(contains('ثوان')));
  });

  test('mileage unit and verification document labels localize in English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(MileageUnit.km.localizedLabel(l10n), 'KM');
    expect(MileageUnit.mile.localizedLabel(l10n), 'MI');
    expect(
      VerificationDocumentType.localizedLabel(
        VerificationDocumentType.nationalId,
        l10n,
      ),
      'National ID',
    );
    expect(
      VerificationDocumentType.localizedLabel(
        VerificationDocumentType.driversLicense,
        l10n,
      ),
      'Driving license',
    );
    expect(
      VerificationDocumentType.localizedLabel(
        VerificationDocumentType.passport,
        l10n,
      ),
      'Passport',
    );
  });
}
