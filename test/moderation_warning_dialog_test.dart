import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/core/moderation/moderation_warning_dialog.dart';
import 'package:Sello/core/moderation/posting_ban_utils.dart';

void main() {
  testWidgets('censored dialog is modal with amber icon and حسناً button',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showModerationWarningDialog(
                  context,
                  variant: ModerationDialogVariant.censored,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('تنبيه'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('حسناً'), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pump();
    expect(find.text('تنبيه'), findsOneWidget);

    await tester.tap(find.text('حسناً'));
    await tester.pumpAndSettle();
    expect(find.text('تنبيه'), findsNothing);
  });

  testWidgets('blocked dialog uses red icon and block title', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showModerationWarningDialog(
                  context,
                  variant: ModerationDialogVariant.blocked,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text('تم الحظر'), findsOneWidget);
    expect(find.byIcon(Icons.block_rounded), findsOneWidget);

    final icon = tester.widget<Icon>(find.byIcon(Icons.block_rounded));
    expect(icon.color, AppColors.rejected);
  });

  testWidgets('blocked dialog shows first-time ban body', (tester) async {
    const banInfo = PostingBanInfo(isFirstBan: true);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showModerationWarningDialog(
                  context,
                  variant: ModerationDialogVariant.blocked,
                  banInfo: banInfo,
                ),
                child: const Text('open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.textContaining('يومين'), findsOneWidget);
  });
}
