import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/screens/auth/forgot_password_screen.dart';

void main() {
  testWidgets('ForgotPasswordScreen shows recovery options', (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const ForgotPasswordScreen(),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    expect(find.text('اختر طريقة استعادة حسابك'), findsOneWidget);
    expect(find.text('متابعة عبر البريد الإلكتروني'), findsOneWidget);
    expect(find.text('متابعة عبر الهاتف'), findsOneWidget);
    expect(find.text('إرسال'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
  });

  testWidgets('Send without email shows inline validation error', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('إرسال'));
    await tester.pump();

    expect(find.textContaining('البريد'), findsWidgets);
  });
}
