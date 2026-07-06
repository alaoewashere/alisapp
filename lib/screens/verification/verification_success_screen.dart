import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../features/auth/widgets/auth_form_styles.dart';

/// Screen 4 — submission success.
class VerificationSuccessScreen extends ConsumerStatefulWidget {
  const VerificationSuccessScreen({super.key});

  @override
  ConsumerState<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends ConsumerState<VerificationSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                ScaleTransition(
                  scale: _scale,
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.approved,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 52,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  strings.verificationSentSuccess,
                  style: AppFonts.cairo(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  strings.verificationReviewNotice,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 14,
                    height: 1.55,
                    color: AppColors.textMuted,
                  ),
                ),
                const Spacer(),
                AuthPrimaryButton(
                  label: strings.backToHome,
                  onPressed: () => context.go(AppRoutes.home),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
