import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/router/app_router.dart';
import 'package:Sello/features/auth/presentation/sign_up_screen.dart';
import 'package:Sello/screens/legal/privacy_policy_screen.dart';
import 'package:Sello/screens/legal/terms_of_use_screen.dart';

void main() {
  testWidgets('TermsOfUseScreen shows sections without agree button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TermsOfUseScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('شروط الاستخدام'), findsOneWidget);
    expect(find.text('مقدمة'), findsOneWidget);
    expect(find.text('أوافق على الشروط'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('إنهاء الخدمة'), findsOneWidget);
  });

  testWidgets('PrivacyPolicyScreen shows sections without agree button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: PrivacyPolicyScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('سياسة الخصوصية'), findsOneWidget);
    expect(find.text('ما المعلومات التي نجمعها'), findsOneWidget);
    expect(find.text('أوافق على سياسة الخصوصية'), findsNothing);

    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('التواصل معنا'), findsOneWidget);
  });

  testWidgets('SignUpScreen create account enabled when required fields filled',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: AppRoutes.signUp,
          builder: (_, _) => const SignUpScreen(),
        ),
        GoRoute(
          path: AppRoutes.terms,
          builder: (_, _) => const TermsOfUseScreen(),
        ),
        GoRoute(
          path: AppRoutes.privacy,
          builder: (_, _) => const PrivacyPolicyScreen(),
        ),
      ],
      initialLocation: AppRoutes.signUp,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );
    await tester.pump();

    final createButton = find.widgetWithText(FilledButton, 'إنشاء حساب');
    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('signup_first_name')), 'محمد');
    await tester.enterText(find.byKey(const Key('signup_last_name')), 'أحمد');
    await tester.pump();

    expect(tester.widget<FilledButton>(createButton).onPressed, isNull);

    await tester.enterText(
      find.byType(TextFormField).at(2),
      'user@example.com',
    );
    await tester.enterText(
      find.byType(TextFormField).at(3),
      'Password1!',
    );
    await tester.enterText(
      find.byType(TextFormField).at(4),
      'Password1!',
    );
    await tester.pump();

    expect(tester.widget<FilledButton>(createButton).onPressed, isNotNull);

    await tester.tap(find.byKey(const Key('signup_terms_link')));
    await tester.pumpAndSettle();
    expect(find.text('أوافق على الشروط'), findsNothing);
    expect(find.text('مقدمة'), findsOneWidget);
  });
}
