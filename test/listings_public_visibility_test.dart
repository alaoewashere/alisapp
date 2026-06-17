import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards public listing feeds: every browse/search/seller-preview query must
/// filter `status = approved` at the repository layer (RLS is defense in depth).
void main() {
  final repoSource = File(
    'lib/features/listings/data/listings_repository.dart',
  ).readAsStringSync();

  final publicMethods = <String>[
    'getFeaturedListings',
    'getRecentListings',
    '_filteredListingsQuery',
    'getSearchSuggestions',
    'getSellerListings',
    'countSellerActiveListings',
  ];

  for (final method in publicMethods) {
    test('$method filters approved listings', () {
      final needle = method == '_filteredListingsQuery'
          ? 'dynamic _filteredListingsQuery'
          : method;
      final start = repoSource.indexOf(needle);
      expect(start, greaterThan(-1), reason: 'method $method not found');

      final nextMethod = repoSource.indexOf(
        method == '_filteredListingsQuery' ? 'dynamic _applyFilters' : 'Future<',
        start + needle.length,
      );
      final blockEnd = nextMethod == -1 ? repoSource.length : nextMethod;
      final block = repoSource.substring(start, blockEnd);

      expect(
        block,
        contains(".eq('status', 'approved')"),
        reason: '$method must eq status approved',
      );
    });
  }

  test('my listings fetch does not require approved on all rows', () {
    final start = repoSource.indexOf('fetchMyListings(');
    expect(start, greaterThan(-1));
    final block = repoSource.substring(
      start,
      repoSource.indexOf('fetchMyListingsByStatus', start),
    );
    expect(block, isNot(contains(".eq('status', 'approved')")));
  });

  test('favorites repository filters approved listings in query', () {
    final favoritesSource = File(
      'lib/features/favorites/data/favorites_repository.dart',
    ).readAsStringSync();
    expect(favoritesSource, contains('.eq(\'listings.status\', \'approved\')'));
    expect(favoritesSource, contains('listings!inner'));
  });
}
