import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:my_app/features/splash/presentation/splash_screen.dart';

void main() {
  testWidgets('SplashScreen shows Sello wordmark and navigates to /home', (tester) async {
    final router = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(
          path: '/splash',
          builder: (_, _) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (_, _) => const Scaffold(body: Text('home')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(routerConfig: router),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.byType(RichText), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 2900));
    await tester.pump();

    expect(find.text('home'), findsOneWidget);
  });
}
