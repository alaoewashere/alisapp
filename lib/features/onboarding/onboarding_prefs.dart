import 'package:shared_preferences/shared_preferences.dart';

const _introSeenKey = 'intro_onboarding_seen_v1';

/// True once the user has seen (or skipped) the first-run intro slides.
Future<bool> isIntroOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_introSeenKey) ?? false;
}

Future<void> markIntroOnboardingSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_introSeenKey, true);
}
