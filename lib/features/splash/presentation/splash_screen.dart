import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';

/// Minimal 2.8s intro splash — white background, logo elastic-in, Sello wordmark.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const logoAsset = 'assets/images/logo.png';
  static const duration = Duration(milliseconds: 2800);
  static const brandGreen = Color(0xFF1EC878);
  static const textDark = Color(0xFF1a1a1a);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _textOpacity;
  late final Animation<double> _textDy;
  late final Animation<double> _underlineOpacity;
  late final Animation<double> _underlineWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: SplashScreen.duration,
    );

    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 900 / 2800, curve: Curves.elasticOut),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 900 / 2800, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(700 / 2800, 1300 / 2800, curve: Curves.easeOutCubic),
      ),
    );

    _textDy = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(700 / 2800, 1300 / 2800, curve: Curves.easeOutCubic),
      ),
    );

    _underlineOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(1200 / 2800, 1700 / 2800, curve: Curves.easeOut),
      ),
    );

    _underlineWidth = Tween<double>(begin: 0, end: 60).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(1200 / 2800, 1700 / 2800, curve: Curves.easeOut),
      ),
    );

    _controller.forward().whenComplete(_navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final languageDone = await isLanguageOnboardingComplete();
    final session =
        SupabaseConfig.isConfigured ? supabase.auth.currentSession : null;

    if (!mounted) return;

    if (!languageDone && session == null) {
      context.go('${AppRoutes.language}?onboarding=true');
    } else if (session != null) {
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.phone);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Opacity(
                  opacity: _logoOpacity.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Image.asset(
                      SplashScreen.logoAsset,
                      width: 120,
                      height: 120,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Opacity(
                  opacity: _textOpacity.value.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, _textDy.value),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: 'Sello',
                            style: GoogleFonts.cairo(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                              color: SplashScreen.brandGreen,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Opacity(
                          opacity: _underlineOpacity.value.clamp(0.0, 1.0),
                          child: Container(
                            width: _underlineWidth.value,
                            height: 2,
                            decoration: BoxDecoration(
                              color: SplashScreen.brandGreen,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
