import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final repoSource = File(
    'lib/features/listings/data/listings_repository.dart',
  ).readAsStringSync();

  test('_applyFilters applies area_name equality filter', () {
    final start = repoSource.indexOf('dynamic _applyFilters');
    expect(start, greaterThan(-1));

    final end = repoSource.indexOf('dynamic _applySorting', start);
    final block = repoSource.substring(start, end);

    expect(block, contains("filters.areaName"));
    expect(block, contains(".eq('area_name', filters.areaName!)"));
  });
}
