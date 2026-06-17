import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/validators.dart';
import 'package:my_app/features/auth/presentation/sign_up_screen.dart';

void main() {
  group('Validators signup', () {
    test('email rejects invalid addresses', () {
      expect(Validators.email('bad'), isNotNull);
      expect(Validators.email('user@example.com'), isNull);
    });

    test('confirmPassword requires match', () {
      expect(Validators.confirmPassword('abc', 'xyz'), isNotNull);
      expect(Validators.confirmPassword('secret12', 'secret12'), isNull);
    });

    test('signUpPassword requires mixed character classes', () {
      expect(Validators.signUpPassword('password'), isNotNull);
      expect(Validators.signUpPassword('Password1!'), isNull);
    });
  });

  testWidgets('SignUpScreen shows hero and form labels', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('أنشئ حسابك'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsNWidgets(2));
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.byType(ClipPath), findsNothing);
    expect(find.text('الاسم الأول'), findsOneWidget);
    expect(find.text('الاسم الأخير'), findsOneWidget);
    expect(find.text('تأكيد كلمة المرور'), findsOneWidget);
    expect(find.text('رقم الهاتف'), findsNothing);
    expect(find.text('سجّل دخولك'), findsOneWidget);
  });

  testWidgets('SignUpScreen keeps typed first and last names', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SignUpScreen(),
        ),
      ),
    );

    await tester.pump();

    await tester.enterText(
      find.byKey(const Key('signup_first_name')),
      'محمد',
    );
    await tester.enterText(
      find.byKey(const Key('signup_last_name')),
      'أحمد',
    );

    final firstField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('signup_first_name')),
        matching: find.byType(TextFormField),
      ),
    );
    final lastField = tester.widget<TextFormField>(
      find.descendant(
        of: find.byKey(const Key('signup_last_name')),
        matching: find.byType(TextFormField),
      ),
    );

    expect(firstField.controller?.text, 'محمد');
    expect(lastField.controller?.text, 'أحمد');
  });
}
