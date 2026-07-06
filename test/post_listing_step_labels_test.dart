import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/listings/constants/post_listing_step_labels.dart';
import 'package:Sello/l10n/app_localizations_ar.dart';

void main() {
  test('postListingStepAppBarTitle uses Arabic ordinals', () {
    final l10n = AppLocalizationsAr();
    expect(postListingStepAppBarTitle(l10n, 1), 'الخطوة الأولى');
    expect(postListingStepAppBarTitle(l10n, 2), 'الخطوة الثانية');
    expect(postListingStepAppBarTitle(l10n, 8), 'الخطوة الثامنة');
  });
}
