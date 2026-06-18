import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/username_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../features/profile/data/profile_repository.dart';
import '../../../shared/widgets/username_availability_indicator.dart';
import '../providers/auth_provider.dart';
import '../providers/pending_signup_provider.dart';
import '../widgets/auth_form_styles.dart';
import '../widgets/auth_hero_header.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _formError;
  UsernameState _usernameState = UsernameState.idle;
  Timer? _usernameDebounce;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    _usernameController.addListener(_onUsernameChanged);

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
    _usernameDebounce?.cancel();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _usernameController.text;
    _usernameDebounce?.cancel();

    if (text.isEmpty) {
      setState(() => _usernameState = UsernameState.idle);
      return;
    }

    final normalized = normalizeUsername(text);
    if (!isValidUsernameFormat(normalized)) {
      setState(() => _usernameState = UsernameState.tooShort);
      return;
    }

    _usernameDebounce = Timer(const Duration(milliseconds: 600), () {
      _checkUsernameAvailability(text);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    final normalized = normalizeUsername(username);
    if (!isValidUsernameFormat(normalized)) {
      if (mounted) setState(() => _usernameState = UsernameState.tooShort);
      return;
    }

    setState(() => _usernameState = UsernameState.checking);

    try {
      final available = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(normalized);
      if (!mounted) return;
      setState(() {
        _usernameState =
            available ? UsernameState.available : UsernameState.taken;
      });
    } catch (_) {
      if (mounted) setState(() => _usernameState = UsernameState.idle);
    }
  }

  String? _usernameValidator(String? value) {
    final raw = value?.trim() ?? '';
    if (raw.isEmpty) return 'أدخل اسم المستخدم';
    final normalized = normalizeUsername(raw);
    if (!isValidUsernameFormat(normalized)) {
      return '3–20 حرفاً: أحرف إنجليزية وأرقام و _ فقط';
    }
    if (_usernameState == UsernameState.taken) {
      return 'اسم المستخدم مستخدم بالفعل';
    }
    if (_usernameState == UsernameState.checking ||
        _usernameState == UsernameState.idle) {
      return 'انتظر التحقق من اسم المستخدم';
    }
    return null;
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
    final username = normalizeUsername(_usernameController.text.trim());
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

    if (_usernameState != UsernameState.available) {
      setState(() => _formError = _usernameValidator(_usernameController.text));
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
          username: username,
        );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    switch (result) {
      case Success():
        final route = await resolvePostAuthRoute(ref);
        if (mounted) context.go(route);
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
      backgroundColor: AppColors.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthDarkHeader(
            overline: 'أنشئ حسابك',
            title: 'إنشاء حساب',
            showLogo: false,
            leading: TextButton(
              onPressed: signUpLoading
                  ? null
                  : () {
                      ref.read(authNotifierProvider.notifier).enterGuestMode();
                      context.go(AppRoutes.home);
                    },
              child: Text(
                'تخطي',
                style: AppFonts.sans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
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
                            grouped: false,
                            loginStyle: true,
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
                          const SizedBox(height: 24),
                          AuthPillField(
                            key: const Key('signup_last_name'),
                            label: 'الاسم الأخير',
                            grouped: false,
                            loginStyle: true,
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
                          const SizedBox(height: 24),
                          AuthPillField(
                            key: const Key('signup_username'),
                            label: 'اسم المستخدم',
                            grouped: false,
                            loginStyle: true,
                            controller: _usernameController,
                            hintText: 'username',
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.ltr,
                            textAlign: TextAlign.left,
                            maxLength: 20,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z0-9_]'),
                              ),
                            ],
                            validator: _usernameValidator,
                            prefixText: '@ ',
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          if (_usernameState != UsernameState.idle)
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: UsernameAvailabilityIndicator(
                                state: _usernameState,
                              ),
                            ),
                          const SizedBox(height: 24),
                          AuthPillField(
                            label: 'البريد الإلكتروني',
                            grouped: false,
                            loginStyle: true,
                            controller: _emailController,
                            hintText: 'example@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: Validators.email,
                          ),
                          const SizedBox(height: 24),
                          AuthPillField(
                            label: 'كلمة المرور',
                            grouped: false,
                            loginStyle: true,
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
                          const SizedBox(height: 24),
                          AuthPillField(
                            label: 'تأكيد كلمة المرور',
                            grouped: false,
                            loginStyle: true,
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
                              style: AppFonts.cairo(
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
                              style: AppFonts.sans(
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
                                style: AppFonts.sans(
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
                                style: AppFonts.sans(
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
