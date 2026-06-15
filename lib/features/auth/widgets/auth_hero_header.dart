import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/app_logo.dart';

/// Curved primary-green hero header for login / OTP screens.
class AuthHeroHeader extends StatelessWidget {
  const AuthHeroHeader({
    super.key,
    required this.title,
    this.subtitle = '',
    this.overline,
    this.leading,
    this.height = 280,
    this.showLogo = true,
    this.heroSlideAnimation,
    this.logoFadeAnimation,
    this.logoScaleAnimation,
    this.textFadeAnimation,
    this.textSlideAnimation,
  });

  final String title;
  final String subtitle;
  final String? overline;
  final Widget? leading;
  final double height;
  final bool showLogo;
  final Animation<Offset>? heroSlideAnimation;
  final Animation<double>? logoFadeAnimation;
  final Animation<double>? logoScaleAnimation;
  final Animation<double>? textFadeAnimation;
  final Animation<Offset>? textSlideAnimation;

  @override
  Widget build(BuildContext context) {
    final greenBackground = ClipPath(
      clipper: const _AuthHeroWaveClipper(),
      child: Container(
        width: double.infinity,
        height: height,
        color: AppColors.primary,
      ),
    );

    final animatedBackground = heroSlideAnimation != null
        ? SlideTransition(
            position: heroSlideAnimation!,
            child: greenBackground,
          )
        : greenBackground;

    Widget buildLogo() {
      final logo = ColorFiltered(
        colorFilter: const ColorFilter.mode(
          Colors.white,
          BlendMode.srcIn,
        ),
        child: const AppLogo(size: 80),
      );

      if (logoFadeAnimation == null && logoScaleAnimation == null) {
        return logo;
      }

      Widget child = logo;
      if (logoScaleAnimation != null) {
        child = ScaleTransition(
          scale: logoScaleAnimation!,
          child: child,
        );
      }
      if (logoFadeAnimation != null) {
        child = FadeTransition(
          opacity: logoFadeAnimation!,
          child: child,
        );
      }
      return child;
    }

    Widget buildOverline() {
      if (overline == null || overline!.isEmpty) {
        return const SizedBox.shrink();
      }

      final overlineWidget = Text(
        overline!,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: Colors.white.withValues(alpha: 0.82),
          height: 1.35,
        ),
      );

      if (textFadeAnimation == null && textSlideAnimation == null) {
        return overlineWidget;
      }

      Widget child = overlineWidget;
      if (textSlideAnimation != null) {
        child = SlideTransition(
          position: textSlideAnimation!,
          child: child,
        );
      }
      if (textFadeAnimation != null) {
        child = FadeTransition(
          opacity: textFadeAnimation!,
          child: child,
        );
      }
      return child;
    }

    Widget buildTitle() {
      final titleWidget = Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      );

      if (textFadeAnimation == null && textSlideAnimation == null) {
        return titleWidget;
      }

      Widget child = titleWidget;
      if (textSlideAnimation != null) {
        child = SlideTransition(
          position: textSlideAnimation!,
          child: child,
        );
      }
      if (textFadeAnimation != null) {
        child = FadeTransition(
          opacity: textFadeAnimation!,
          child: child,
        );
      }
      return child;
    }

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          animatedBackground,
          if (leading != null)
            SafeArea(
              bottom: false,
              child: Align(
                alignment: Alignment.topRight,
                child: leading,
              ),
            ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, leading != null ? 4 : 12, 24, 12),
              child: Center(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.center,
                      child: ConstrainedBox(
                        constraints:
                            BoxConstraints(maxWidth: constraints.maxWidth),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showLogo) ...[
                              buildLogo(),
                              const SizedBox(height: 12),
                            ],
                            if (overline != null && overline!.isNotEmpty) ...[
                              buildOverline(),
                              const SizedBox(height: 8),
                            ],
                            buildTitle(),
                            if (subtitle.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(
                                subtitle,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white.withValues(alpha: 0.82),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthHeroWaveClipper extends CustomClipper<Path> {
  const _AuthHeroWaveClipper();

  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, 0);

    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height * 0.68);

    path.cubicTo(
      size.width * 0.92,
      size.height * 0.92,
      size.width * 0.62,
      size.height * 1.02,
      size.width * 0.38,
      size.height * 0.9,
    );

    path.cubicTo(
      size.width * 0.12,
      size.height * 0.78,
      size.width * 0.04,
      size.height * 0.96,
      0,
      size.height * 0.82,
    );

    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
