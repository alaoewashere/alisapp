import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'patrol_helpers.dart';

void main() {
  patrolTest(
    'guest can open home and browse categories header',
    skip: !isPatrolSupabaseConfigured,
    ($) async {
      await pumpSelloApp($);

      await $('تصفح الفئات').waitUntilVisible(
        timeout: const Duration(seconds: 30),
      );
      expect($('تصفح الفئات'), findsOneWidget);
    },
  );
}
