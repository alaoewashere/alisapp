import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
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
    final strings = ref.read(appLocalizationsProvider);
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
              strings.passwordResetResent,
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
    final strings = ref.watch(appLocalizationsProvider);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AuthDarkHeader(
              title: strings.passwordResetSentTitle,
              subtitle: strings.passwordResetSentSubtitle,
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
                      strings.passwordResetInstructions,
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.pureWhite.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: strings.resendLink,
                      loading: _resending,
                      loginStyle: true,
                      onPressed: _resending ? null : _resend,
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: Text(
                        strings.backToLogin,
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
