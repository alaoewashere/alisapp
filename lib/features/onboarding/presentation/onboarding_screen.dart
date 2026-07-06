import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../onboarding_prefs.dart';

class _Slide {
  const _Slide({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

const _slides = <_Slide>[
  _Slide(
    icon: Icons.map_outlined,
    title: 'كل العراق على الخريطة',
    body: 'تصفّح الإعلانات القريبة منك على خريطة حية، وشوف وين معروض كل شي.',
  ),
  _Slide(
    icon: Icons.add_circle_outline_rounded,
    title: 'انشر إعلانك بثواني',
    body: 'صوّر، حدّد السعر والموقع، وانشر — بيع أي شي بأبسط الخطوات.',
  ),
  _Slide(
    icon: Icons.notifications_active_outlined,
    title: 'تنبيهات ذكية',
    body: 'سجّل اهتمامك ووصلك تنبيه أول ما ينعرض إعلان يناسبك.',
  ),
];

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  bool get _isLast => _index == _slides.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await markIntroOnboardingSeen();
    if (mounted) context.go(AppRoutes.home);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF131315),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF18181C), Color(0xFF0E0E10)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Skip
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8, left: 8),
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(
                      'تخطّي',
                      style: AppFonts.cairo(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++) ...[
                    if (i > 0) const SizedBox(width: 7),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: i == _index ? 22 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? AppColors.volt
                            : AppColors.textMuted.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 28),
              // CTA
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _next,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.volt,
                      foregroundColor: AppColors.canvas,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: AppFonts.cairo(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    child: Text(_isLast ? 'ابدأ الآن' : 'التالي'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});

  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Volt-tinted icon medallion with a soft glow.
          Container(
            width: 132,
            height: 132,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.volt.withValues(alpha: 0.10),
              border: Border.all(
                color: AppColors.volt.withValues(alpha: 0.30),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.volt.withValues(alpha: 0.18),
                  blurRadius: 30,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(slide.icon, size: 60, color: AppColors.volt),
          ),
          const SizedBox(height: 36),
          Text(
            slide.title,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: AppColors.pureWhite,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            slide.body,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 15,
              color: AppColors.textMuted,
              height: 1.7,
            ),
          ),
        ],
      ),
    );
  }
}
