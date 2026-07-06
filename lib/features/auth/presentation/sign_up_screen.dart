import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/result.dart';
import '../../../core/l10n/validators_l10n.dart';
import '../../../l10n/app_localizations.dart';
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
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

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

    for (final controller in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.addListener(_onFieldChanged);
    }

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
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _emailController,
      _passwordController,
      _confirmPasswordController,
    ]) {
      controller.removeListener(_onFieldChanged);
    }
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (mounted) setState(() {});
  }

  bool get _allRequiredFieldsFilled =>
      _firstNameController.text.trim().isNotEmpty &&
      _lastNameController.text.trim().isNotEmpty &&
      _emailController.text.trim().isNotEmpty &&
      _passwordController.text.isNotEmpty &&
      _confirmPasswordController.text.isNotEmpty;

  Future<void> _openTerms() async {
    if (_isSubmitting) return;
    await context.push(AppRoutes.terms);
  }

  Future<void> _openPrivacy() async {
    if (_isSubmitting) return;
    await context.push(AppRoutes.privacy);
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

    final strings = ref.read(appLocalizationsProvider);
    final confirmError =
        ValidatorsL10n.confirmPassword(confirmPassword, password, strings);
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
      case Success(value: false):
        // Email confirmation required — go to verification screen.
        if (mounted) {
          context.push(
            '${AppRoutes.emailVerify}?email=${Uri.encodeComponent(email)}&purpose=signup',
          );
        }
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

  String? _requiredNameValidator(
    String? value,
    String label,
    AppLocalizations strings,
  ) {
    return ValidatorsL10n.requiredField(value?.trim(), strings, fieldLabel: label);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authNotifierProvider);
    final strings = ref.watch(appLocalizationsProvider);
    final signUpLoading =
        _isSubmitting ||
        (auth.status == AuthFlowStatus.loading && auth.phone == null);
    final canCreateAccount = _allRequiredFieldsFilled && !signUpLoading;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthDarkHeader(
            title: strings.createAccount,
            showLogo: false,
            leading: TextButton(
              onPressed: signUpLoading
                  ? null
                  : () {
                      ref.read(authNotifierProvider.notifier).enterGuestMode();
                      context.go(AppRoutes.home);
                    },
              child: Text(
                strings.skip,
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
                            label: strings.firstName,
                            grouped: false,
                            loginStyle: true,
                            controller: _firstNameController,
                            hintText: strings.firstNameHint,
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.givenName],
                            validator: (value) =>
                                _requiredNameValidator(value, strings.firstName, strings),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          AuthPillField(
                            key: const Key('signup_last_name'),
                            label: strings.lastName,
                            grouped: false,
                            loginStyle: true,
                            controller: _lastNameController,
                            hintText: strings.lastNameHint,
                            textInputAction: TextInputAction.next,
                            textDirection: TextDirection.rtl,
                            textAlign: TextAlign.right,
                            textCapitalization: TextCapitalization.words,
                            autofillHints: const [AutofillHints.familyName],
                            validator: (value) =>
                                _requiredNameValidator(value, strings.lastName, strings),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          AuthPillField(
                            label: strings.emailLabel,
                            grouped: false,
                            loginStyle: true,
                            controller: _emailController,
                            hintText: 'example@email.com',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: (v) => ValidatorsL10n.email(v, strings),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
                          ),
                          const SizedBox(height: 24),
                          AuthPillField(
                            label: strings.passwordLabel,
                            grouped: false,
                            loginStyle: true,
                            controller: _passwordController,
                            hintText: '••••••••',
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: (v) => ValidatorsL10n.signUpPassword(v, strings),
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
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
                            label: strings.confirmPasswordLabel,
                            grouped: false,
                            loginStyle: true,
                            controller: _confirmPasswordController,
                            hintText: '••••••••',
                            obscureText: _obscureConfirmPassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.newPassword],
                            onChanged: (_) {
                              if (_formError != null) {
                                setState(() => _formError = null);
                              }
                            },
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
                        Center(
                          child: RichText(
                            key: const Key('signup_agreement_text'),
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppFonts.sans(
                                fontSize: 12,
                                color: AppColors.textMuted,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(text: strings.signUpAgreementPrefix),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    key: const Key('signup_terms_link'),
                                    onTap: _openTerms,
                                    child: Text(
                                      strings.termsLink,
                                      style: AppFonts.sans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.volt,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: strings.andConnector),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.baseline,
                                  baseline: TextBaseline.alphabetic,
                                  child: GestureDetector(
                                    key: const Key('signup_privacy_link'),
                                    onTap: _openPrivacy,
                                    child: Text(
                                      strings.privacyLink,
                                      style: AppFonts.sans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.volt,
                                        height: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: canCreateAccount ? _submit : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: canCreateAccount
                                  ? AppColors.volt
                                  : AppColors.volt.withValues(alpha: 0.3),
                              disabledBackgroundColor:
                                  AppColors.volt.withValues(alpha: 0.3),
                              foregroundColor: AppColors.canvas,
                              disabledForegroundColor: AppColors.canvas,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: signUpLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.canvas,
                                    ),
                                  )
                                : Text(
                                    strings.createAccount,
                                    style: AppFonts.sans(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.canvas,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                strings.alreadyHaveAccount,
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
                                  strings.signInLink,
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

