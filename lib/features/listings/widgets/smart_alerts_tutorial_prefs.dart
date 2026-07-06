import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/secure_log.dart';

String smartAlertsTutorialSeenKeyFor(String userId) =>
    'smart_alerts_tutorial_seen_$userId';

Future<bool> hasSeenSmartAlertsTutorial(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = smartAlertsTutorialSeenKeyFor(userId);
  final seen = prefs.getBool(key) ?? false;
  SecureLog.debug('Tutorial flag value ($key): $seen');
  return seen;
}

Future<void> markSmartAlertsTutorialSeen(String userId) async {
  final prefs = await SharedPreferences.getInstance();
  final key = smartAlertsTutorialSeenKeyFor(userId);
  await prefs.setBool(key, true);
  SecureLog.debug('Tutorial flag set ($key): true');
}
