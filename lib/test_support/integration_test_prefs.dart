import 'package:shared_preferences/shared_preferences.dart';

import '../features/home/widgets/home_heatmap_prefs.dart';
import '../features/listings/widgets/smart_alerts_tutorial_prefs.dart';

const patrolTestUserId = 'patrol-test-user';

/// Skips first-run coachmarks so Patrol flows stay deterministic.
Future<void> markOnboardingTutorialsSeenForTests({
  String userId = patrolTestUserId,
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(smartAlertsTutorialSeenKeyFor(userId), true);
  await prefs.setBool(heatmapTutorialSeenKeyFor(userId), true);
}
