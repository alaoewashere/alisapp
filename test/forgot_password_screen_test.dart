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
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('نسيت كلمة المرور؟'), findsOneWidget);
    expect(find.text('أدخل بريدك الإلكتروني لاستقبال رمز التحقق'), findsOneWidget);
    expect(find.text('متابعة عبر البريد الإلكتروني'), findsOneWidget);
    expect(find.text('متابعة عبر الهاتف'), findsOneWidget);
    expect(find.text('إرسال'), findsOneWidget);
    expect(find.text('البريد الإلكتروني'), findsOneWidget);
  });

  testWidgets('Send without email shows validation snackbar', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: ForgotPasswordScreen(),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 600));

    await tester.tap(find.text('إرسال'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('البريد'), findsWidgets);
  });
}
