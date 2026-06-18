import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/listings/widgets/steps/step2_form_common.dart';

void main() {
  testWidgets('Step2ChipSelector shows text field when أخرى is selected', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Step2ChipSelector(
            options: const ['أ', 'ب'],
            selected: selected,
            onSelected: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('أخرى'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'قيمة مخصصة');
    await tester.pump();

    expect(selected, 'قيمة مخصصة');
  });

  testWidgets('Step2LabeledDropdown shows text field when أخرى is picked', (
    tester,
  ) async {
    String? selected;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Step2LabeledDropdown(
            label: 'اختبار',
            value: selected,
            items: const ['أ', 'ب'],
            onChanged: (value) => selected = value,
          ),
        ),
      ),
    );

    await tester.tap(find.text('اختر'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('أخرى').last);
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'خيار خاص');
    await tester.pump();

    expect(selected, 'خيار خاص');
  });
}
