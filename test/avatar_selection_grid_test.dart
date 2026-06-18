import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/dicebear_avatars.dart';
import 'package:Sello/shared/widgets/avatar_selection_grid.dart';
import 'package:Sello/shared/widgets/dicebear_avatar_cell.dart';

void main() {
  testWidgets('AvatarSelectionGrid renders 30 DiceBear cells', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AvatarSelectionGrid(
            selectedSeed: DiceBearAvatars.defaultSeed,
            onSelected: (_) {},
          ),
        ),
      ),
    );

    expect(find.byType(DiceBearAvatarCell), findsNWidgets(30));
    expect(find.text('اختر صورة افتراضية'), findsOneWidget);
  });
}
