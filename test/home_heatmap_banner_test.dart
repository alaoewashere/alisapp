import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:Sello/core/router/app_router.dart';
import 'package:Sello/features/home/widgets/home_heatmap_banner.dart';
import 'package:Sello/features/home/widgets/home_heatmap_prefs.dart';
import 'package:Sello/features/home/widgets/home_heatmap_tutorial.dart';
import 'package:Sello/features/home/widgets/home_top_bar_icon_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('HomeTopBarIconButton is icon-only circular 40x40', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HomeTopBarIconButton(
            icon: Icons.map_outlined,
            onTap: () {},
          ),
        ),
      ),
    );

    expect(find.byType(HomeTopBarIconButton), findsOneWidget);
    expect(find.text('كثافة الإعلانات'), findsNothing);
    final size = tester.getSize(find.byType(HomeTopBarIconButton));
    expect(size.width, HomeTopBarIconButton.size);
    expect(size.height, HomeTopBarIconButton.size);
    final buttonMaterial = tester.widget<Material>(
      find.descendant(
        of: find.byType(HomeTopBarIconButton),
        matching: find.byType(Material),
      ),
    );
    expect(buttonMaterial.elevation, 0);
  });

  testWidgets('heatmap and favorites buttons share the same widget type', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            leading: HomeTopBarIconButton(
              icon: Icons.favorite_border_rounded,
              onTap: () {},
            ),
            actions: [
              HomeTopBarIconButton(
                icon: Icons.map_outlined,
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(HomeTopBarIconButton), findsNWidgets(2));
    expect(find.text('كثافة الإعلانات'), findsNothing);
  });

  testWidgets('HomeTopBarIconButton tap navigates to heatmap', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) => HomeTopBarIconButton(
            icon: Icons.map_outlined,
            onTap: () => openHomeHeatmap(context),
          ),
        ),
        GoRoute(
          path: AppRoutes.heatmap,
          builder: (_, _) => const Scaffold(body: Text('heatmap')),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.tap(find.byType(HomeTopBarIconButton));
    await tester.pumpAndSettle();

    expect(find.text('heatmap'), findsOneWidget);
  });

  testWidgets('tutorial overlay shows copy and فهمت button', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            actions: [
              HomeTopBarIconButton(
                key: key,
                icon: Icons.map_outlined,
                onTap: () {},
              ),
            ],
          ),
          body: Stack(
            children: [
              const SizedBox.expand(),
              HomeHeatmapTutorialOverlay(
                targetKey: key,
                onDismiss: () {},
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('اكتشف كثافة الإعلانات'),
      findsOneWidget,
    );
    expect(find.text('فهمت'), findsOneWidget);
  });

  test('markHeatmapTutorialSeen persists flag', () async {
    expect(await hasSeenHeatmapTutorial(), isFalse);
    await markHeatmapTutorialSeen();
    expect(await hasSeenHeatmapTutorial(), isTrue);
  });
}
