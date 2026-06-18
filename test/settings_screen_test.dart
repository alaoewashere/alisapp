import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/screens/settings/settings_screen.dart';

void main() {
  testWidgets('SettingsScreen shows title and section label', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('الإعدادات'), findsOneWidget);
    expect(find.text('إعدادات أخرى'), findsOneWidget);
    expect(find.text('تفاصيل الحساب'), findsOneWidget);
    expect(find.text('حذف الحساب'), findsOneWidget);
    expect(find.text('تسجيل الخروج'), findsOneWidget);
    expect(find.text('اللغة'), findsOneWidget);
    expect(find.text('الوضع الداكن'), findsNothing);
  });
}
