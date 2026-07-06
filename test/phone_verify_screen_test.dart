import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/l10n/app_localizations.dart';
import 'package:Sello/screens/auth/phone_verify_screen.dart';

void main() {
  testWidgets('PhoneVerifyScreen verify button disabled until 4 digits',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PhoneVerifyScreen(phone: '+905342660876'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final verifyButton = find.widgetWithText(FilledButton, 'التحقق');
    expect(verifyButton, findsOneWidget);
    expect(tester.widget<FilledButton>(verifyButton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    expect(tester.widget<FilledButton>(verifyButton).onPressed, isNotNull);
  });

  testWidgets('PhoneVerifyScreen shows lock icon and phone number',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const PhoneVerifyScreen(phone: '+905342660876'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(find.text('+905342660876'), findsOneWidget);
    expect(find.text('أدخل رمز التحقق'), findsOneWidget);
  });
}
