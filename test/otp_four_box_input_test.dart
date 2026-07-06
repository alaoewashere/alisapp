import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/screens/auth/widgets/otp_four_box_input.dart';

void main() {
  testWidgets('OtpFourBoxInput fills boxes left to right', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OtpFourBoxInput(controller: controller),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), '1234');
    await tester.pump();

    expect(controller.text, '1234');
    expect(find.text('1'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('4'), findsOneWidget);
  });

  testWidgets('OtpFourBoxInput uses LTR directionality', (tester) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
            body: OtpFourBoxInput(controller: controller),
          ),
        ),
      ),
    );

    final directionality = tester.widget<Directionality>(
      find.ancestor(
        of: find.byType(Row),
        matching: find.byType(Directionality),
      ).first,
    );
    expect(directionality.textDirection, TextDirection.ltr);
  });

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
