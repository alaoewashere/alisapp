import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/features/home/widgets/home_hero_section.dart';
import 'package:Sello/features/home/widgets/home_section_view_all_link.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  Future<void> pumpWithLocale(WidgetTester tester, Locale locale) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Column(
            children: [
              const HomeHeroSection(),
              HomeSectionViewAllLink(onPressed: () {}),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Home hero shows English when locale is en', (tester) async {
    await pumpWithLocale(tester, const Locale('en'));

    expect(find.text('Buy & sell'), findsOneWidget);
    expect(find.text('View all'), findsOneWidget);
  });

  testWidgets('Home hero shows Arabic when locale is ar', (tester) async {
    await pumpWithLocale(tester, const Locale('ar'));

    expect(find.text('اشتري و بيع'), findsOneWidget);
    expect(find.text('عرض الكل'), findsOneWidget);
  });
}
