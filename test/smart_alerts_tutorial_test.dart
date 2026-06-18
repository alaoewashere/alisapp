import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sello/features/listings/widgets/smart_alerts_tutorial_prefs.dart';
import 'package:Sello/shared/widgets/feature_tutorial_overlay.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('smart alerts tutorial shows Arabic copy and فهمت', (tester) async {
    final key = GlobalKey();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              IconButton(
                key: key,
                icon: const Icon(Icons.notifications_none_outlined),
                onPressed: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              const SizedBox.expand(),
              FeatureTutorialOverlay(
                targetKey: key,
                onDismiss: () {},
                title:
                    'حدد معايير بحثك مرة واحدة واستلم إشعاراً فورياً عند نشر إعلان جديد يطابقها',
                subtitle: 'اضغط على أيقونة الجرس لإدارة تنبيهاتك الذكية',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(
      find.textContaining('حدد معايير بحثك'),
      findsOneWidget,
    );
    expect(find.text('فهمت'), findsOneWidget);
  });

  test('markSmartAlertsTutorialSeen persists separate flag', () async {
    expect(await hasSeenSmartAlertsTutorial(), isFalse);
    await markSmartAlertsTutorialSeen();
    expect(await hasSeenSmartAlertsTutorial(), isTrue);
  });
}
