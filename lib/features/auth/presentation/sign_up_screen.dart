import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../providers/auth_provider.dart';
import '../providers/pending_signup_provider.dart';
import '../widgets/auth_form_styles.dart';
import '../widgets/auth_hero_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;
  late final AnimationController _heroController;
  late final Animation<Offset> _heroSlideAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _textFadeAnimation;
  late final Animation<Offset> _textSlideAnimation;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _heroController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _heroSlideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutCubic),
    );

    _logoFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOut),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.7, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: Curves.easeOutBack),
    );

    const textInterval = Interval(0.375, 1, curve: Curves.easeOut);

    _textFadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _heroController, curve: textInterval),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _heroController, curve: textInterval),
    );

    _heroController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = ref.read(pendingSignupProvider);
      if (pending == null) return;
      if (_firstNameController.text.isEmpty) {
        _firstNameController.text = pending.firstName;
      }
      if (_lastNameController.text.isEmpty) {
        _lastNameController.text = pending.lastName;
      }
      if (_emailController.text.isEmpty) {
        _emailController.text = pending.email;
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _heroController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;

    FocusManager.instance.primaryFocus?.unfocus();
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (kDebugMode) {
      debugPrint(
        'SignUpScreen submit → firstName="$firstName" lastName="$lastName" '
        'email="$email"',
      );
    }

    final confirmError = Validators.confirmPassword(confirmPassword, password);
    if (confirmError != null) {
      setState(() => _formError = confirmError);
      return;
    }

    setState(() {
      _formError = null;
      _isSubmitting = true;
    });

    ref.read(pendingSignupProvider.notifier).set(
          PendingSignupData(
            firstName: firstName,
            lastName: lastName,
            email: email,
          ),
        );

    final result = await ref.read(authNotifierProvider.notifier).signUpWithEmailPassword(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        context.go(AppRoutes.usernameSetup);
      case Failure(:final message):
        setState(() => _formError = message);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        ref.read(authNotifierProvider.notifier).clearError();
    }
  }

  String? _requiredNameValidator(String? value, String label) {
    return Validators.requiredField(value?.trim(), label: label);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final signUpLoading =
        _isSubmitting ||
        (auth.status == AuthFlowStatus.loading && auth.phone == null);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthHeroHeader(
            overline: 'أنشئ حسابك',
            title: 'إنشاء حساب',
            showLogo: false,
            heroSlideAnimation: _heroSlideAnimation,
            logoFadeAnimation: _logoFadeAnimation,
            logoScaleAnimation: _logoScaleAnimation,
            textFadeAnimation: _textFadeAnimation,
            textSlideAnimation: _textSlideAnimation,
            leading: TextButton(
              onPressed: signUpLoading
                  ? null
                  : () {
                      ref.read(authNotifierProvider.notifier).enterGuestMode();
                      context.go(AppRoutes.home);
                    },
              child: Text(
                'تخطي',
                style: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.92),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AuthPillField(
                            key: const Key('signup_first_name'),
                            label: 'الاسم الأول',
                            controller: _firstNameController,
                            hintText: 'محمد',
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.givenName],
                            validator: (value) =>
                                _requiredNameValidator(value, 'الاسم الأول'),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthPillField(
                            key: const Key('signup_last_name'),
                            label: 'الاسم الأخير',
                            controller: _lastNameController,
                            hintText: 'أحمد',
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.familyName],
                            validator: (value) =>
                                _requiredNameValidator(value, 'الاسم الأخير'),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 20),
                          AuthPillField(
                            label: 'البريد الإلكتروني',
                            controller: _emailController,
                            hintText: 'example@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 20),
                          AuthPillField(
                            label: 'كلمة المرور',
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: Validators.signUpPassword,
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
                          const SizedBox(height: 20),
                          AuthPillField(
                            label: 'تأكيد كلمة المرور',
                            controller: _confirmPasswordController,
                            hintText: '••••••••',
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textMuted,
                                size: 22,
                              ),
                            ),
                          ),
                          if (_formError != null) ...[
                            const SizedBox(height: 16),
                            Text(
                              _formError!,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.cairo(
                                color: Theme.of(context).colorScheme.error,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              'بالتسجيل، أنت توافق على ',
                              style: GoogleFonts.cairo(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                'شروط الاستخدام وسياسة الخصوصية',
                                style: GoogleFonts.cairo(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        AuthPrimaryButton(
                          label: 'إنشاء حساب',
                          loading: signUpLoading,
                          onPressed: signUpLoading ? null : _submit,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'لديك حساب بالفعل؟ ',
                                style: GoogleFonts.cairo(
                                  fontSize: 15,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              GestureDetector(
                                onTap: signUpLoading
                                    ? null
                                    : () => context.go(AppRoutes.login),
                                child: Text(
                                  'سجّل دخولك',
                                  style: GoogleFonts.cairo(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
