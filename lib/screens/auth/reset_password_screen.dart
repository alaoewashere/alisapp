import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/auth/widgets/auth_hero_header.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  ConsumerState<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final passwordError = Validators.password(password);
    final confirmError = Validators.confirmPassword(confirm, password);
    final error = passwordError ?? confirmError;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    setState(() => _submitting = true);
    final result =
        await ref.read(authNotifierProvider.notifier).updatePassword(password);
    if (!mounted) return;
    setState(() => _submitting = false);

    switch (result) {
      case Success():
        context.go(AppRoutes.login);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير كلمة المرور',
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
              title: 'كلمة المرور الجديدة',
              subtitle: 'أدخل كلمة مرور جديدة لحسابك',
              leading: AppBackButton(
                onPressed: _submitting ? null : () => context.pop(),
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
                    AuthPillField(
                      label: 'كلمة المرور الجديدة',
                      controller: _passwordController,
                      hintText: '••••••••',
                      obscureText: _obscurePassword,
                      grouped: false,
                      loginStyle: true,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscurePassword = !_obscurePassword),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.pureWhite.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    AuthPillField(
                      label: 'تأكيد كلمة المرور',
                      controller: _confirmController,
                      hintText: '••••••••',
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      grouped: false,
                      loginStyle: true,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: AppColors.pureWhite.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AuthPrimaryButton(
                      label: 'تأكيد',
                      loading: _submitting,
                      loginStyle: true,
                      onPressed: _submitting ? null : _submit,
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
