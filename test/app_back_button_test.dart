import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/shared/widgets/app_back_button.dart';

void main() {
  testWidgets('AppBackButton uses Field Carbon circle styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            leading: AppBackButton(),
          ),
        ),
      ),
    );

    final iconButton = tester.widget<IconButton>(find.byType(IconButton));
    final style = iconButton.style;
    expect(style?.backgroundColor?.resolve({}), AppColors.fieldCarbon);
    expect(style?.foregroundColor?.resolve({}), AppColors.pureWhite);
    expect(find.byIcon(Icons.arrow_back), findsOneWidget);
  });
}
