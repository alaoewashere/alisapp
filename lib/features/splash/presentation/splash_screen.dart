import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../onboarding/onboarding_prefs.dart';
import '../../listings/providers/post_listing_provider.dart' show allCategoriesProvider;

/// First-launch splash — a slow, choreographed Souqak brand reveal, then home.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  static const backgroundColor = Color(0xFF131315);
  static const logoAsset = AppAssets.appLogo;
  static const brandNameAr = 'سـوقك';
  static const taglineAr = 'تطبيقك الأول للبيع والشراء';

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro; // staggered entrance (plays once)
  late final AnimationController _glow; // breathing halo (loops)
  late final AnimationController _shimmer; // light sweep over the name (loops)
  late final AnimationController _progress; // bottom loading bar (plays once)

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _glowFade;
  late final Animation<double> _nameFade;
  late final Animation<Offset> _nameSlide;
  late final Animation<double> _underline;
  late final Animation<double> _taglineFade;

  @override
  void initState() {
    super.initState();

    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
    _progress = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    Animation<double> seg(double begin, double end,
            [Curve curve = Curves.easeOut]) =>
        CurvedAnimation(
          parent: _intro,
          curve: Interval(begin, end, curve: curve),
        );

    _logoFade = seg(0.0, 0.35);
    _logoScale = Tween<double>(begin: 0.74, end: 1.0)
        .animate(seg(0.0, 0.5, Curves.easeOutBack));
    _glowFade = seg(0.08, 0.5);
    _nameFade = seg(0.35, 0.65);
    _nameSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(seg(0.35, 0.78, Curves.easeOutCubic));
    _underline = seg(0.55, 0.88, Curves.easeOutCubic);
    _taglineFade = seg(0.7, 1.0);

    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _intro.forward();
        _progress.forward();
      }
    });
    // Warm the categories cache now — splash already has a fixed 4.2s dead
    // window, so the search tab's first paint doesn't eat this fetch cost.
    ref.read(allCategoriesProvider);
    Future<void>.delayed(const Duration(milliseconds: 4200), _navigateNext);
  }

  Future<void> _navigateNext() async {
    if (!mounted) return;

    final onboardingComplete = await isLanguageOnboardingComplete();
    if (!mounted) return;

    if (!onboardingComplete) {
      // Default to Arabic on first launch — skip the language picker.
      await ref.read(localeProvider.notifier).setLocale(const Locale('ar'));
      if (!mounted) return;
      await ref.read(localeProvider.notifier).markOnboardingComplete();
      if (!mounted) return;
    }

    // First-run users see the intro slides before the home screen.
    final introSeen = await isIntroOnboardingSeen();
    if (!mounted) return;
    context.go(introSeen ? AppRoutes.home : AppRoutes.intro);
  }

  @override
  void dispose() {
    _intro.dispose();
    _glow.dispose();
    _shimmer.dispose();
    _progress.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    return Scaffold(
      backgroundColor: SplashScreen.backgroundColor,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF18181C), Color(0xFF0E0E10)],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Soft, slowly breathing volt halo behind the logo.
            Center(
              child: AnimatedBuilder(
                animation: Listenable.merge([_intro, _glow]),
                builder: (context, child) {
                  return Opacity(
                    opacity: _glowFade.value,
                    child: Transform.scale(
                      scale: 0.88 + _glow.value * 0.18,
                      child: Container(
                        width: 360,
                        height: 360,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.volt.withValues(alpha: 0.20),
                              AppColors.volt.withValues(alpha: 0.0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Logo + shimmering brand name + underline.
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: const AppLogo(size: 124),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FadeTransition(
                    opacity: _nameFade,
                    child: SlideTransition(
                      position: _nameSlide,
                      child: AnimatedBuilder(
                        animation: _shimmer,
                        builder: (context, child) {
                          final x = _shimmer.value * 3 - 1.5;
                          return ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (bounds) {
                              return LinearGradient(
                                begin: Alignment(x, 0),
                                end: Alignment(x + 1.0, 0),
                                colors: const [
                                  Colors.white,
                                  AppColors.volt,
                                  Colors.white,
                                ],
                                stops: const [0.35, 0.5, 0.65],
                              ).createShader(bounds);
                            },
                            child: child,
                          );
                        },
                        child: const Text(
                          SplashScreen.brandNameAr,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'ThmanyahSerifDisplay',
                            fontWeight: FontWeight.bold,
                            fontSize: 46,
                            color: Colors.white,
                            letterSpacing: 1.0,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Volt accent line that draws out under the name.
                  AnimatedBuilder(
                    animation: _underline,
                    builder: (context, child) => Container(
                      width: 90 * _underline.value,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.volt.withValues(alpha: 0.55),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Tagline + slim filling loading bar at the bottom.
            Positioned(
              left: 0,
              right: 0,
              bottom: 44,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FadeTransition(
                    opacity: _taglineFade,
                    child: Text(
                      strings.splashTagline,
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  FadeTransition(
                    opacity: _logoFade,
                    child: _LoadingBar(progress: _progress),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Thin volt bar that fills over the splash duration.
class _LoadingBar extends StatelessWidget {
  const _LoadingBar({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 132,
        height: 3,
        child: ColoredBox(
          color: AppColors.surfaceMuted,
          child: AnimatedBuilder(
            animation: progress,
            builder: (context, child) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: Curves.easeInOut.transform(progress.value),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.volt.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
