import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/theme/app_theme.dart';
import 'package:Sello/core/utils/digit_input_formatter.dart';
import 'package:Sello/features/listings/widgets/steps/step2_form_common.dart';
import 'package:Sello/theme/app_text_styles.dart';

void main() {
  testWidgets('Step2IqdField accepts western digits', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Step2IqdField(label: 'السعر', controller: controller),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '12345');
    await tester.pump();
    expect(controller.text, '12345');
    expect(find.text('12345'), findsOneWidget);
  });

  test('digitsOnly formatter rejects eastern arabic numerals', () {
    final formatter = FilteringTextInputFormatter.digitsOnly;
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '٥'),
    );
    expect(result.text, isEmpty);
  });

  testWidgets('Step2IqdField accepts eastern arabic digits', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Step2IqdField(label: 'السعر', controller: controller),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '٥٠٠');
    await tester.pump();
    expect(controller.text, '500');
    expect(find.text('500'), findsOneWidget);
  });

  test('appDigitsOnly accepts eastern arabic numerals', () {
    final formatter = appDigitsOnly();
    final result = formatter.formatEditUpdate(
      const TextEditingValue(text: ''),
      const TextEditingValue(text: '٥'),
    );
    expect(result.text, '5');
  });

  testWidgets('price style renders digit text widget', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: Text('98765', style: AppTextStyles.price),
        ),
      ),
    );
    expect(find.text('98765'), findsOneWidget);
  });
}
