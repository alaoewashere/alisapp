import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';

void main() {
  test('location validation requires governorate only', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);

    expect(notifier.validateStep(3), 'اختر المحافظة');

    notifier.updateField('governorate', 'baghdad');
    expect(notifier.validateStep(3), isNull);
  });
}
