import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:Sello/core/constants/app_strings.dart';

import 'patrol_helpers.dart';

void main() {
  patrolTest(
    'guest search with no matches shows Arabic empty state',
    skip: !isPatrolSupabaseConfigured,
    ($) async {
      const query = 'no-match-xyz-12345';

      await pumpSelloApp($);
      await openSearchTab($);
      await submitNoMatchSearch($, query: query);

      await $(#search_empty_results_message).waitUntilVisible(
        timeout: const Duration(seconds: 60),
      );

      expect($(AppStrings.noResults), findsOneWidget);
      expect($(#search_empty_results_detail), findsOneWidget);
    },
  );
}
