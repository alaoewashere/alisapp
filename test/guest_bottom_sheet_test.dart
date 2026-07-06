import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/app_assets.dart';
import 'package:Sello/features/auth/widgets/guest_bottom_sheet.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  testWidgets('Guest bottom sheet uses readable text and dark background',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('ar'),
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showGuestBottomSheet(context),
                  child: const Text('open'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    final sheet = tester.widget<Material>(
      find.descendant(
        of: find.byType(BottomSheet),
        matching: find.byType(Material),
      ).first,
    );
    expect(sheet.color, const Color(0xFF18181A));

    final title = tester.widget<Text>(find.text('سجّل دخولك للمتابعة'));
    expect(title.style?.color, Colors.white);
    expect(title.style?.fontWeight, FontWeight.bold);
    expect(title.style?.fontSize, 20);

    final subtitle = tester.widget<Text>(
      find.text('أنشئ حساباً أو سجّل الدخول لاستخدام هذه الميزة'),
    );
    expect(subtitle.style?.color, Colors.white.withValues(alpha: 0.65));
    expect(subtitle.style?.fontSize, 14);

    final cancel = tester.widget<Text>(find.text('إلغاء'));
    expect(cancel.style?.color, const Color(0xFFD4FF3A));

    final logo = tester.widget<Image>(find.byType(Image));
    expect(logo.image, const AssetImage(AppAssets.appLogo));
  });
}
