import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/app_assets.dart';
import 'package:Sello/shared/widgets/app_logo.dart';

void main() {
  testWidgets('AppLogo loads bundled asset', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: AppLogo(size: 120)),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    final image = tester.widget<Image>(find.byType(Image));
    expect(image.image, isA<AssetImage>());
    expect((image.image as AssetImage).assetName, AppAssets.appLogo);
  });

  testWidgets('AppBrandHeader shows Sello', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(body: AppBrandHeader()),
        ),
      ),
    );

    expect(find.text('Sello'), findsOneWidget);
    expect(find.text('العراق'), findsOneWidget);
  });
}
