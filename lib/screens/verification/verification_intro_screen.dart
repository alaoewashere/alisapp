import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../features/auth/widgets/auth_hero_header.dart';

/// Screen 1 — verification intro with green hero header.
class VerificationIntroScreen extends StatelessWidget {
  const VerificationIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            AuthHeroHeader(
              height: 260,
              showLogo: false,
              title: 'توثيق الحساب',
              subtitle: 'قبل المتابعة، يرجى توثيق هويتك',
              leading: AppBackButton(onPressed: () => context.pop()),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.manage_search_rounded,
                        size: 44,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'لماذا التوثيق؟',
                      style: AppFonts.cairo(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'توثيق حسابك يمنحك شارة الثقة الزرقاء ويزيد من ثقة المشترين في إعلاناتك. '
                      'نراجع وثائقك بسرية تامة ولا نشاركها مع أي طرف.',
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        fontSize: 14,
                        height: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _Bullet(text: 'شارة «بائع موثّق» على ملفك وإعلاناتك'),
                    _Bullet(text: 'مراجعة خلال 24 ساعة'),
                    _Bullet(text: 'وثائقك محفوظة بشكل آمن'),
                  ],
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: AuthPrimaryButton(
                  label: 'توثيق الهوية ←',
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
            child: Icon(Icons.check_circle, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: AppFonts.cairo(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
