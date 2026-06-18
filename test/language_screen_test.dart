import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/screens/settings/language_screen.dart';

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

    expect(find.text('مرحباً بك في سيلو'), findsOneWidget);
    expect(find.text('اختر لغتك'), findsOneWidget);
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

    expect(find.text('CONTINUE'), findsOneWidget);
  });

  testWidgets('LanguageScreen from settings shows AppBar title', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LanguageScreen(isOnboarding: false),
        ),
      ),
    );

    expect(find.text('اللغة'), findsOneWidget);
    expect(find.byType(AppBar), findsOneWidget);
  });
}
