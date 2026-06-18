import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/auth/widgets/auth_hero_header.dart';
import 'package:Sello/shared/widgets/app_logo.dart';

void main() {
  testWidgets('AuthHeroHeader shows welcome copy and logo', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthHeroHeader(
            title: 'مرحباً بك',
            subtitle: 'سجّل دخولك للمتابعة',
          ),
        ),
      ),
    );

    expect(find.text('مرحباً بك'), findsOneWidget);
    expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
  });

  testWidgets('AuthDarkHeader uses dark canvas without wave clipper', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AuthDarkHeader(
            title: 'مرحباً بك',
            subtitle: 'سجّل دخولك للمتابعة',
          ),
        ),
      ),
    );

    expect(find.text('مرحباً بك'), findsOneWidget);
    expect(find.text('سجّل دخولك للمتابعة'), findsOneWidget);
    expect(find.byType(AppLogo), findsOneWidget);
    expect(find.byType(ClipPath), findsNothing);
    expect(find.byType(AuthDarkHeader), findsOneWidget);
  });

  testWidgets('AuthDarkHeader supports overline and leading without logo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AuthDarkHeader(
            overline: 'أنشئ حسابك',
            title: 'إنشاء حساب',
            showLogo: false,
            leading: TextButton(onPressed: () {}, child: const Text('تخطي')),
          ),
        ),
      ),
    );

    expect(find.text('أنشئ حسابك'), findsOneWidget);
    expect(find.text('إنشاء حساب'), findsOneWidget);
    expect(find.text('تخطي'), findsOneWidget);
    expect(find.byType(AppLogo), findsNothing);
    expect(find.byType(ClipPath), findsNothing);
  });

  testWidgets('AuthHeroHeader animates when animations are provided', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: _AnimatedHeroHarness(),
      ),
    );

    await tester.pump();
    expect(find.byType(AppLogo), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 800));
    await tester.pump();
    expect(find.text('مرحباً بك'), findsOneWidget);
  });
}

class _AnimatedHeroHarness extends StatefulWidget {
  @override
  State<_AnimatedHeroHarness> createState() => _AnimatedHeroHarnessState();
}

class _AnimatedHeroHarnessState extends State<_AnimatedHeroHarness>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(_controller);
    _fade = Tween<double>(begin: 0, end: 1).animate(_controller);
    _scale = Tween<double>(begin: 0.7, end: 1).animate(_controller);
    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.375, 1, curve: Curves.easeOut),
      ),
    );
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.375, 1, curve: Curves.easeOut),
      ),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthHeroHeader(
        title: 'مرحباً بك',
        subtitle: 'سجّل دخولك للمتابعة',
        heroSlideAnimation: _slide,
        logoFadeAnimation: _fade,
        logoScaleAnimation: _scale,
        textFadeAnimation: _textFade,
        textSlideAnimation: _textSlide,
      ),
    );
  }
}
