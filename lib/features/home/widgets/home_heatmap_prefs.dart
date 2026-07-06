import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/secure_log.dart';

String heatmapTutorialSeenKeyFor(String userId) =>
    'heatmap_tutorial_seen_$userId';

Future<bool> hasSeenHeatmapTutorial(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = heatmapTutorialSeenKeyFor(userId);
  final seen = prefs.getBool(key) ?? false;
  SecureLog.debug('Tutorial flag value ($key): $seen');
  return seen;
}

Future<void> markHeatmapTutorialSeen(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = heatmapTutorialSeenKeyFor(userId);
  await prefs.setBool(key, true);
  SecureLog.debug('Tutorial flag set ($key): true');
}
