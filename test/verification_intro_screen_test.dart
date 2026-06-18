import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/features/auth/widgets/auth_hero_header.dart';
import 'package:Sello/screens/verification/verification_intro_screen.dart';

void main() {
  testWidgets('verification intro uses dark header and readable body text',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const VerificationIntroScreen(),
            ),
          ],
        ),
      ),
    );

    expect(find.text('توثيق الحساب'), findsOneWidget);
    expect(find.text('لماذا التوثيق؟'), findsOneWidget);
    expect(find.byType(AuthDarkHeader), findsOneWidget);
    expect(find.byType(AuthHeroHeader), findsNothing);

    final title = tester.widget<Text>(find.text('توثيق الحساب'));
    expect(title.style?.color, AppColors.pureWhite);
    expect(title.style?.fontSize, 22);

    final sectionTitle = tester.widget<Text>(find.text('لماذا التوثيق؟'));
    expect(sectionTitle.style?.color, AppColors.pureWhite);

    final icon = tester.widget<Icon>(find.byIcon(Icons.manage_search_rounded));
    expect(icon.color, AppColors.volt);

    final checkIcons = tester.widgetList<Icon>(find.byIcon(Icons.check_circle));
    expect(checkIcons.every((icon) => icon.color == AppColors.volt), isTrue);
  });
}
