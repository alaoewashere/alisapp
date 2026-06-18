import 'package:shared_preferences/shared_preferences.dart';

const heatmapTutorialSeenKey = 'heatmap_tutorial_seen';

Future<bool> hasSeenHeatmapTutorial() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(heatmapTutorialSeenKey) ?? false;
}

Future<void> markHeatmapTutorialSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(heatmapTutorialSeenKey, true);
}
