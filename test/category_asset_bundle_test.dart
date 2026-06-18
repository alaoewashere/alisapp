import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/category_asset_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('root category PNGs are bundled in the Flutter asset manifest', () async {
    const slugs = [
      'cars',
      'real_estate',
      'electronics',
      'buy_sell',
      'tutoring',
      'veh_automobile',
      're_residential',
      'elec_smartphones',
      'souq_mobile',
      'tutor_school',
      'jobs',
      'jobs_it',
      'pets',
      'pets_cats',
      'home_help',
      'home_cooking',
      'jobs_it_web_dev',
    ];

    for (final slug in slugs) {
      final path = CategoryAssetIcons.displayAssetForSlug(slug);
      expect(path, isNotNull, reason: 'missing display asset for $slug');
      await rootBundle.load(path!);
    }

    expect(CategoryAssetIcons.displayAssetForSlug('re_residential_sale_apartment'), isNull);
    expect(CategoryAssetIcons.displayAssetForSlug('veh_atv'), isNull);
  });
}
