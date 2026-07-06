import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../features/auth/widgets/auth_hero_header.dart';

/// Screen 1 — verification intro with dark canvas header.
class VerificationIntroScreen extends ConsumerWidget {
  const VerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            AuthDarkHeader(
              showLogo: false,
              title: strings.verifyAccountTitle,
              subtitle: strings.verifyAccountSubtitle,
              leading: AppBackButton(onPressed: () => context.pop()),
              titleStyle: AppFonts.cairo(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.pureWhite,
                height: 1.2,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: const BoxDecoration(
                        color: AppColors.fieldCarbon,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.manage_search_rounded,
                        size: 44,
                        color: AppColors.volt,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      strings.whyVerification,
                      style: AppFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      strings.verificationBenefitsBody,
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Bullet(text: strings.verifiedSellerBadge),
                    _Bullet(text: strings.reviewWithin24Hours),
                    _Bullet(text: strings.documentsStoredSecurely),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AuthPrimaryButton(
                  label: strings.verifyIdentityAction,
                  onPressed: () =>
                      context.push(AppRoutes.verificationDocumentType),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.check_circle, size: 16, color: AppColors.volt),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppFonts.cairo(
                fontSize: 13,
                color: AppColors.pureWhite,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
