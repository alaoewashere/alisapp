import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/features/listings/providers/post_listing_provider.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  group('PostListingNotifier contact preferences', () {
    test('validateStep requires contact preference on contact step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);

      expect(notifier.validateStep(5), 'اختر تفضيل التواصل');

      notifier.setContactPreference(ListingContactPreference.phoneOnly);
      expect(notifier.validateStep(5), isNull);
    });

    test('maxStep includes contact step before review', () {
      expect(const PostListingState().maxStep, 7);
    });
  });

  group('PostListingNotifier listing package', () {
    test('confirmListingPackage advances from package step', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(postListingProvider.notifier);
      notifier.goToStep(6);

      notifier.confirmListingPackage();
      expect(container.read(postListingProvider).currentStep, 7);
    });

    test('packageStep is after contact step', () {
      expect(const PostListingState().contactStep, 5);
      expect(const PostListingState().packageStep, 6);
    });
  });

  group('ListingModel contact preference parsing', () {
    test('reads contact preference from metadata when column absent', () {
      final listing = ListingModel.fromJson({
        'id': '1',
        'user_id': 'u1',
        'category_id': 1,
        'title_ar': 'test',
        'description_ar': 'desc',
        'price': 1000,
        'city': 'baghdad',
        'governorate': 'baghdad',
        'status': 'pending',
        'availability': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'metadata': {'contact_preference': 'messages_only'},
      });

      expect(listing.contactPreference, ListingContactPreference.messagesOnly);
    });
  });
}
