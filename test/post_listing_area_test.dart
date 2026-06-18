import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/constants/iraq_neighborhoods.dart';
import 'package:Sello/features/listings/providers/post_listing_provider.dart';

void main() {
  test('applyMapPickerResult auto-suggests nearest neighborhood', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);
    notifier.updateField('governorate', 'baghdad');

    notifier.applyMapPickerResult(
      latitude: 33.2989176206327,
      longitude: 44.3372610211372,
      address: 'بغداد',
    );

    final state = container.read(postListingProvider);
    expect(state.areaName, 'المنصور');
    expect(state.areaNameLocked, isFalse);
    expect(state.latitude, closeTo(33.2989176206327, 0.0001));
  });

  test('manual neighborhood selection locks area from map auto-suggest', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);
    notifier.updateField('governorate', 'baghdad');
    notifier.setAreaNameFromSlug('baghdad_karrada');

    notifier.applyMapPickerResult(
      latitude: 33.2989176206327,
      longitude: 44.3372610211372,
    );

    final state = container.read(postListingProvider);
    expect(state.areaName, 'الكرادة');
    expect(state.areaNameLocked, isTrue);
  });

  test('clearLocation clears area_name and coordinates', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);
    notifier.updateField('governorate', 'baghdad');
    notifier.setAreaNameFromSlug('baghdad_karrada');
    notifier.applyMapPickerResult(latitude: 33.31, longitude: 44.45);

    notifier.clearLocation();

    final state = container.read(postListingProvider);
    expect(state.areaName, isNull);
    expect(state.latitude, isNull);
    expect(state.longitude, isNull);
    expect(state.areaNameLocked, isFalse);
  });

  test('governorate change clears previously selected area', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);
    notifier.updateField('governorate', 'baghdad');
    notifier.setAreaNameFromSlug('baghdad_karrada');

    notifier.updateField('governorate', 'basra');

    final state = container.read(postListingProvider);
    expect(state.areaName, isNull);
    expect(state.areaNameLocked, isFalse);
  });

  test('selectedAreaSlug resolves from stored Arabic area name', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(postListingProvider.notifier);
    notifier.setAreaNameFromSlug('baghdad_jadriya');

    expect(notifier.selectedAreaSlug, 'baghdad_jadriya');
    expect(
      neighborhoodByNameAr(container.read(postListingProvider).areaName!)?.nameAr,
      'الجادرية',
    );
  });
}
