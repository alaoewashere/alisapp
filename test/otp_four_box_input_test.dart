import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/screens/auth/widgets/otp_four_box_input.dart';

void main() {
  testWidgets('OtpFourBoxInput renders four boxes', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpFourBoxInput(controller: controller),
        ),
      ),
    );

    expect(find.byType(OtpFourBoxInput), findsOneWidget);
    controller.text = '12';
    await tester.pump();
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
  });
}
