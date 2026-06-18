import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/result.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/auth/widgets/auth_hero_header.dart';

class PasswordResetEmailSentScreen extends ConsumerStatefulWidget {
  const PasswordResetEmailSentScreen({super.key, required this.email});

  final String email;

  @override
  ConsumerState<PasswordResetEmailSentScreen> createState() =>
      _PasswordResetEmailSentScreenState();
}

class _PasswordResetEmailSentScreenState
    extends ConsumerState<PasswordResetEmailSentScreen> {
  bool _resending = false;

  Future<void> _resend() async {
    setState(() => _resending = true);
    final result = await ref
        .read(authNotifierProvider.notifier)
        .resetPasswordForEmail(widget.email);
    if (!mounted) return;
    setState(() => _resending = false);

    switch (result) {
      case Success():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال الرابط مرة أخرى',
              style: AppFonts.cairo(fontWeight: FontWeight.w600),
            ),
          ),
        );
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthDarkHeader(
              title: 'تم إرسال الرابط',
              subtitle: 'تم إرسال رابط إعادة التعيين إلى بريدك',
              leading: AppBackButton(
                onPressed: () => context.go(AppRoutes.login),
              ),
              titleStyle: AppFonts.sans(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.pureWhite,
                height: 1.2,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.volt,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'افتح الرابط في بريدك لإنشاء كلمة مرور جديدة. قد يستغرق وصول الرسالة بضع دقائق.',
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.pureWhite.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'إعادة الإرسال',
                      loading: _resending,
                      loginStyle: true,
                      onPressed: _resending ? null : _resend,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        'العودة لتسجيل الدخول',
                        style: AppFonts.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.volt,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
