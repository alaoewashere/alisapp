import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/screens/auth/widgets/phone_login_bottom_sheet.dart';

class _SheetOpener extends ConsumerWidget {
  const _SheetOpener();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showPhoneLoginBottomSheet(context, ref),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('phone login bottom sheet shows WhatsApp subtitle and country code',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: _SheetOpener(),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.text('سنرسل لك رمز تحقق عبر واتساب'), findsOneWidget);
    expect(find.text('+966'), findsOneWidget);
    expect(find.text('🇸🇦'), findsOneWidget);
    expect(find.text('إرسال الرمز'), findsOneWidget);

    final title = tester.widget<Text>(find.text('متابعة برقم الهاتف'));
    expect(title.style?.color, AppColors.pureWhite);

    final subtitle = tester.widget<Text>(
      find.text('سنرسل لك رمز تحقق عبر واتساب'),
    );
    expect(subtitle.style?.color, AppColors.textMuted);

    final phoneField = tester.widget<TextField>(find.byType(TextField));
    expect(phoneField.cursorColor, AppColors.volt);
    expect(
      phoneField.style?.color,
      AppColors.pureWhite,
    );

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('إرسال الرمز'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.style?.backgroundColor?.resolve({}), AppColors.volt);
    expect(button.style?.foregroundColor?.resolve({}), AppColors.canvas);
    expect(
      (button.style?.shape?.resolve({}) as RoundedRectangleBorder?)
          ?.borderRadius
          .resolve(TextDirection.rtl)
          .topLeft
          .x,
      14,
    );
  });
}
