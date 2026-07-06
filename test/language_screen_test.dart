import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/app_assets.dart';
import 'package:Sello/screens/settings/language_screen.dart';
import 'package:Sello/shared/widgets/app_logo.dart';

void main() {
  testWidgets('LanguageScreen shows welcome title and three options',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LanguageScreen(),
        ),
      ),
    );

    expect(find.text('مرحباً بك في سـوقك'), findsOneWidget);
    expect(find.text('اختر لغتك'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    final logo = tester.widget<Image>(find.byType(Image));
    expect(logo.image, const AssetImage(AppAssets.appLogo));
    expect(logo.width, 56);
    expect(logo.height, 56);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('العربية'), findsOneWidget);
    expect(find.text('کوردی'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
  });

  testWidgets('LanguageScreen continue label switches with English selection',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LanguageScreen(),
        ),
      ),
    );

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
  });

  testWidgets('LanguageScreen from settings shows AppBar title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LanguageScreen(isOnboarding: false),
        ),
      ),
    );

    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.text('تغيير اللغة'),
      ),
      findsOneWidget,
    );
    expect(find.byType(AppBar), findsOneWidget);
  });
}
