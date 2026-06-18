import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/constants/app_colors.dart';
import 'package:Sello/core/constants/verification_constants.dart';
import 'package:Sello/screens/verification/verification_document_type_screen.dart';
import 'package:Sello/screens/verification/verification_upload_screen.dart';

void main() {
  testWidgets('document type rows use field carbon dark styling', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (_, _) => const VerificationDocumentTypeScreen(),
            ),
          ],
        ),
      ),
    );

    final label = tester.widget<Text>(find.text('الهوية الوطنية'));
    expect(label.style?.color, AppColors.pureWhite);
    expect(label.style?.fontSize, 15);

    final icon = tester.widget<Icon>(find.byIcon(Icons.badge_outlined));
    expect(icon.color, AppColors.volt);
  });

  testWidgets('all document type rows remain visible after returning from upload',
      (tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const VerificationDocumentTypeScreen(),
        ),
        GoRoute(
          path: '/upload',
          builder: (_, state) => VerificationUploadScreen(
            documentType: state.uri.queryParameters['type']!,
          ),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp.router(routerConfig: router),
      ),
    );

    await tester.tap(find.text('الهوية الوطنية'));
    await tester.pumpAndSettle();

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('الهوية الوطنية'), findsOneWidget);
    expect(find.text('رخصة القيادة'), findsOneWidget);
    expect(find.text('جواز السفر'), findsOneWidget);
  });

  testWidgets('upload frames and submit button use dark theme styling',
      (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: VerificationUploadScreen(
            documentType: VerificationDocumentType.nationalId,
          ),
        ),
      ),
    );

    final sectionLabel = tester.widget<Text>(find.text('الوجه الأمامي'));
    expect(sectionLabel.style?.color, AppColors.pureWhite);

    final typeLabel = tester.widget<Text>(find.text('الهوية الوطنية'));
    expect(typeLabel.style?.color, AppColors.textMuted);

    final captureText = tester.widget<Text>(find.text('التقاط صورة'));
    expect(captureText.style?.color, AppColors.pureWhite);

    final cameraIcon = tester.widget<Icon>(
      find.byIcon(Icons.photo_camera_outlined),
    );
    expect(cameraIcon.color, AppColors.volt);
  });
}
