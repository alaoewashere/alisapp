import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/verification_constants.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/models/profile_model.dart';

/// Profile entry banner for seller verification status.
class VerificationStatusBanner extends StatelessWidget {
  const VerificationStatusBanner({super.key, required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final status = profile.verificationStatus;

    if (status == VerificationStatus.verified) {
      return _BannerShell(
        color: AppColors.approved.withValues(alpha: 0.12),
        borderColor: AppColors.approved.withValues(alpha: 0.35),
        icon: Icons.verified_outlined,
        iconColor: AppColors.approved,
        text: 'حسابك موثّق ✓',
        textColor: AppColors.approved,
      );
    }

    if (status == VerificationStatus.pending) {
      return _BannerShell(
        color: AppColors.surfaceMuted.withValues(alpha: 0.35),
        borderColor: AppColors.borderLight,
        icon: Icons.hourglass_top_rounded,
        iconColor: AppColors.textMuted,
        text: 'طلب التوثيق قيد المراجعة ⏳',
        textColor: AppColors.textMuted,
      );
    }

    if (status == VerificationStatus.rejected) {
      final reason = profile.verificationRejectionReason?.trim();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _BannerShell(
            color: AppColors.rejected.withValues(alpha: 0.08),
            borderColor: AppColors.rejected.withValues(alpha: 0.3),
            icon: Icons.error_outline_rounded,
            iconColor: AppColors.rejected,
            text: reason != null && reason.isNotEmpty
                ? 'تم رفض طلبك — $reason'
                : 'تم رفض طلب التوثيق',
            textColor: AppColors.rejected,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => context.push(AppRoutes.verificationIntro),
              child: Text(
                'إعادة المحاولة',
                style: AppFonts.cairo(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: AppColors.pending.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () => context.push(AppRoutes.verificationIntro),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.pending.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.lock_outline, color: AppColors.pending, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'وثّق حسابك للحصول على شارة الثقة 🔒',
                  style: AppFonts.cairo(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const Icon(Icons.chevron_left, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BannerShell extends StatelessWidget {
  const _BannerShell({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppFonts.cairo(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
