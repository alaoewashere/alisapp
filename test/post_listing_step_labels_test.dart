import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/features/listings/constants/post_listing_step_labels.dart';

void main() {
  test('postListingStepAppBarTitle uses Arabic ordinals', () {
    expect(postListingStepAppBarTitle(1), 'الخطوة الأولى');
    expect(postListingStepAppBarTitle(2), 'الخطوة الثانية');
    expect(postListingStepAppBarTitle(8), 'الخطوة الثامنة');
  });
}
