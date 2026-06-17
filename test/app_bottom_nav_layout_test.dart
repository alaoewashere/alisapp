import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/shared/widgets/app_bottom_nav.dart';

void main() {
  testWidgets('nav outer padding uses safe area + small gap only', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
          child: Builder(
            builder: (context) {
              final outer = AppBottomNavLayout.barOuterPadding(context);
              expect(outer.left, AppBottomNavLayout.sideMargin);
              expect(outer.bottom, 34 + AppBottomNavLayout.safeBottomGap);
              expect(
                AppBottomNavLayout.scrollBottomPadding(context),
                AppBottomNavLayout.barHeight +
                    34 +
                    AppBottomNavLayout.safeBottomGap,
              );
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  });

  testWidgets('scroll spacer height matches nav clearance', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: MediaQuery(
            data: const MediaQueryData(padding: EdgeInsets.only(bottom: 34)),
            child: AppBottomNavScrollSpacer(),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(SizedBox)).height,
      AppBottomNavLayout.barHeight + 34 + AppBottomNavLayout.safeBottomGap,
    );
  });
}
