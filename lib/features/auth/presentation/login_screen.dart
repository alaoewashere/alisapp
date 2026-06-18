import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../screens/auth/widgets/phone_login_bottom_sheet.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_styles.dart';
import '../widgets/auth_hero_header.dart';
import '../widgets/auth_social_login_row.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final emailError = Validators.email(email);
    final passwordError = Validators.password(password);
    final error = emailError ?? passwordError;

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    final result =
        await ref.read(authNotifierProvider.notifier).signInWithEmailPassword(
              email: email,
              password: password,
            );

    if (!mounted) return;

    switch (result) {
      case Success():
        context.go(AppRoutes.homeNav);
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final googleLoading = ref.watch(isGoogleSignInLoadingProvider);
    final appleLoading = ref.watch(isAppleSignInLoadingProvider);
    final oauthLoading = googleLoading || appleLoading;
    final emailLoading = auth.status == AuthFlowStatus.loading &&
        auth.phone == null &&
        auth.oauthLoading == null;

    final strings = ref.watch(appLocalizationsProvider);

    ref.listen(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          next.oauthLoading != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.errorMessage!)),
        );
        ref.read(authNotifierProvider.notifier).clearError();
      }

      if (next.status == AuthFlowStatus.authenticated &&
          prev?.status != AuthFlowStatus.authenticated &&
          prev?.oauthLoading != null) {
        resolvePostAuthRoute(ref).then((route) {
          if (context.mounted) context.go(route);
        });
      }
    });

    final canSubmit = !emailLoading && !oauthLoading;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthDarkHeader(
            title: 'مرحباً بك',
            subtitle: strings.guestSignInPrompt,
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AuthPillField(
                          label: 'البريد الإلكتروني',
                          controller: _emailController,
                          hintText: 'example@email.com',
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          grouped: false,
                          loginStyle: true,
                        ),
                        const SizedBox(height: 24),
                        AuthPillField(
                          label: 'كلمة المرور',
                          controller: _passwordController,
                          hintText: '••••••••',
                          obscureText: _obscurePassword,
                          textInputAction: TextInputAction.done,
                          grouped: false,
                          loginStyle: true,
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 22,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: canSubmit
                                ? () => context.go(AppRoutes.forgotPassword)
                                : null,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'نسيت كلمة المرور؟',
                              style: AppFonts.sans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.volt,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AuthPrimaryButton(
                          label: strings.login,
                          loading: emailLoading,
                          onPressed: canSubmit ? _signIn : null,
                        ),
                        const SizedBox(height: 20),
                        AuthOrDivider(label: strings.orDivider),
                        const SizedBox(height: 20),
                        AuthSocialLoginRow(
                          googleLoading: googleLoading,
                          appleLoading: appleLoading,
                          onGooglePressed: canSubmit
                              ? () => ref
                                  .read(authNotifierProvider.notifier)
                                  .signInWithGoogle()
                              : null,
                          onApplePressed: canSubmit
                              ? () => ref
                                  .read(authNotifierProvider.notifier)
                                  .signInWithApple()
                              : null,
                          onPhonePressed: canSubmit
                              ? () => showPhoneLoginBottomSheet(context, ref)
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'ليس لديك حساب؟ ',
                            style: AppFonts.sans(
                              fontSize: 15,
                              color: AppColors.textMuted,
                            ),
                          ),
                          GestureDetector(
                            onTap: canSubmit
                                ? () => context.go(AppRoutes.signUp)
                                : null,
                            child: Text(
                              'سجّل الآن',
                              style: AppFonts.sans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
