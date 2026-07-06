import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sello/features/home/widgets/home_heatmap_prefs.dart';
import 'package:Sello/features/listings/widgets/smart_alerts_tutorial_prefs.dart';
import 'package:Sello/test_support/integration_test_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('markOnboardingTutorialsSeenForTests sets uid-scoped coachmark prefs', () async {
    SharedPreferences.setMockInitialValues({});

    await markOnboardingTutorialsSeenForTests();

    final prefs = await SharedPreferences.getInstance();
    expect(
      prefs.getBool(smartAlertsTutorialSeenKeyFor(patrolTestUserId)),
      isTrue,
    );
    expect(
      prefs.getBool(heatmapTutorialSeenKeyFor(patrolTestUserId)),
      isTrue,
    );
  });
}
