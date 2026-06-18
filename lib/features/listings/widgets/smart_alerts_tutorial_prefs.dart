import 'package:shared_preferences/shared_preferences.dart';

const smartAlertsTutorialSeenKey = 'smart_alerts_tutorial_seen';

Future<bool> hasSeenSmartAlertsTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(smartAlertsTutorialSeenKey) ?? false;
}

Future<void> markSmartAlertsTutorialSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(smartAlertsTutorialSeenKey, true);
}
