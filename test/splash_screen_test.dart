import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/constants/app_assets.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:Sello/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows branding with ThmanyahSerifDisplay Bold', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    expect(find.byType(Scaffold), findsOneWidget);
    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, SplashScreen.backgroundColor);

    final logo = tester.widget<Image>(find.byType(Image));
    expect(logo.image, const AssetImage(AppAssets.appLogo));
    expect(logo.width, 110);
    expect(logo.height, 110);
    expect(logo.fit, BoxFit.contain);

    final brandText = tester.widget<Text>(find.text(SplashScreen.brandNameAr));
    expect(brandText.style?.fontFamily, 'ThmanyahSerifDisplay');
    expect(brandText.style?.fontWeight, FontWeight.bold);
    expect(brandText.style?.fontSize, 42);
    expect(brandText.style?.color, Colors.white);
    expect(brandText.style?.letterSpacing, 1.0);

    final tagline = tester.widget<Text>(find.text(SplashScreen.taglineAr));
    expect(tagline.style?.fontFamily, AppFonts.sansFamily);
    expect(tagline.style?.fontSize, 13);
    expect(tagline.style?.color, Colors.white.withValues(alpha: 0.45));

    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('SplashScreen fades in after delay', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: SplashScreen(),
        ),
      ),
    );

    await tester.pump();
    final fadeFinder = find.descendant(
      of: find.byType(SplashScreen),
      matching: find.byType(FadeTransition),
    );
    expect(fadeFinder, findsOneWidget);
    final fadeBefore = tester.widget<FadeTransition>(fadeFinder);
    expect(fadeBefore.opacity.value, 0);

    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 400));
    final fadeMid = tester.widget<FadeTransition>(fadeFinder);
    expect(fadeMid.opacity.value, greaterThan(0));
    expect(fadeMid.opacity.value, lessThan(1));

    await tester.pump(const Duration(milliseconds: 500));
    final fadeEnd = tester.widget<FadeTransition>(fadeFinder);
    expect(fadeEnd.opacity.value, 1);

    await tester.pump(const Duration(seconds: 3));
  });
}
