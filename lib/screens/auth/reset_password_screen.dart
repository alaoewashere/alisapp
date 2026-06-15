import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/auth_form_styles.dart';

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
        context.go(AppRoutes.phone);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم تغيير كلمة المرور',
              style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
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
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            onPressed: _submitting ? null : () => context.pop(),
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Color(0xFF111111),
              size: 20,
            ),
          ),
          title: Text(
            'كلمة المرور الجديدة',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthPillField(
                label: 'كلمة المرور الجديدة',
                controller: _passwordController,
                hintText: '••••••••',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
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
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AuthPrimaryButton(
                label: 'تأكيد',
                loading: _submitting,
                onPressed: _submitting ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
