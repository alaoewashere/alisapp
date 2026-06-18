import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/screens/settings/edit_profile_screen.dart';

void main() {
  testWidgets('EditProfileScreen shows title and save button', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: EditProfileScreen(),
        ),
      ),
    );

    expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
    expect(find.text('حفظ'), findsOneWidget);
  });
}
