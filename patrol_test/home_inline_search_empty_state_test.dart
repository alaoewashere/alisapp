import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:Sello/core/constants/app_strings.dart';

import 'patrol_helpers.dart';

void main() {
  patrolTest(
    'guest home inline search with no matches shows empty state',
    skip: !isPatrolSupabaseConfigured,
    ($) async {
      const query = 'no-match-xyz-12345';

      await pumpSelloApp($);

      await $(#home_search_field).waitUntilVisible();
      await $(#home_search_field).enterText(query);
      await $.pumpAndSettle(timeout: const Duration(seconds: 20));

      await $(AppStrings.noResults).waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      expect($(AppStrings.noResults), findsOneWidget);
    },
  );
}
