import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/features/auth/widgets/auth_form_styles.dart';
import 'package:Sello/widgets/rate_dialog.dart';

class _SheetOpener extends ConsumerWidget {
  const _SheetOpener();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showRateDialog(
            context: context,
            ref: ref,
            listingId: 'listing-1',
            reviewedId: 'user-1',
            reviewedName: 'بائع تجريبي',
            reviewedAvatarSeed: 'seed-1',
            subtitle: 'تقييم البائع بعد إتمام الصفقة',
          ),
          child: const Text('Open'),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('rate dialog uses dark theme styling', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: _SheetOpener(),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    final title = tester.widget<Text>(find.text('كيف كانت تجربتك؟'));
    expect(title.style?.color, AppColors.pureWhite);

    final sellerName = tester.widget<Text>(find.text('بائع تجريبي'));
    expect(sellerName.style?.color, AppColors.pureWhite);

    final emptyStars = tester.widgetList<Icon>(find.byIcon(Icons.star_outline_rounded));
    expect(emptyStars.every((icon) => icon.color == const Color(0x30FFFFFF)), isTrue);
    expect(emptyStars.every((icon) => icon.size == 32), isTrue);

    final commentField = tester.widget<TextField>(find.byType(TextField));
    expect(commentField.cursorColor, AppColors.volt);
    expect(commentField.style?.color, AppColors.pureWhite);

    final button = tester.widget<FilledButton>(
      find.ancestor(
        of: find.text('إرسال التقييم'),
        matching: find.byType(FilledButton),
      ),
    );
    expect(button.style?.backgroundColor?.resolve({}), AppColors.volt);
    expect(button.style?.foregroundColor?.resolve({}), AppColors.canvas);

    expect(find.byType(AuthPrimaryButton), findsOneWidget);
  });
}
