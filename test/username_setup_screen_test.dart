import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/screens/auth/username_setup_screen.dart';

void main() {
  testWidgets('UsernameSetupScreen shows title and continue button',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: UsernameSetupScreen(),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('اختر اسم المستخدم'), findsOneWidget);
    expect(find.text('متابعة'), findsOneWidget);
    expect(find.text('تخطى الآن'), findsOneWidget);
  });
}
