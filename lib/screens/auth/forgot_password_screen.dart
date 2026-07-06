import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/auth/widgets/auth_hero_header.dart';

enum _RecoveryMethod { email, phone }

// WhatsApp OTP costs money per message — off until Twilio is funded.
// Flip to true once TWILIO_* secrets are configured.
const _phoneRecoveryEnabled = false;

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  _RecoveryMethod _selectedMethod = _RecoveryMethod.email;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late Country _selectedCountry;
  bool _sending = false;
  String? _inlineError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _selectedCountry = Country.parse('IQ');
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.login);
    }
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      onSelect: (country) => setState(() => _selectedCountry = country),
    );
  }

  Future<void> _onSendPressed() async {
    final strings = ref.read(appLocalizationsProvider);
    setState(() => _inlineError = null);

    if (_selectedMethod == _RecoveryMethod.email) {
      final email = _emailController.text.trim();
      final emailError = Validators.email(email);
      if (emailError != null) {
        setState(() => _inlineError = emailError);
        return;
      }

      setState(() => _sending = true);
      final registered =
          await ref.read(authRepositoryProvider).isEmailRegistered(email);
      if (!mounted) return;

      switch (registered) {
        case Success(:final value):
          if (!value) {
            setState(() {
              _sending = false;
              _inlineError = strings.emailNotRegistered;
            });
            return;
          }
        case Failure(:final message):
          setState(() {
            _sending = false;
            _inlineError = message;
          });
          return;
      }

      final result = await ref
          .read(authNotifierProvider.notifier)
          .resetPasswordForEmail(email);
      if (!mounted) return;
      setState(() => _sending = false);

      switch (result) {
        case Success():
          context.push(
            '${AppRoutes.passwordResetEmailSent}?email=${Uri.encodeComponent(email)}',
          );
        case Failure(:final message):
          setState(() => _inlineError = message);
      }
      return;
    }

    final isoCode = _selectedCountry.countryCode;
    final localDigits = Validators.normalizeLocalDigits(
      _phoneController.text,
      isoCode,
      phoneCode: _selectedCountry.phoneCode,
    );
    final phoneError = Validators.localPhone(localDigits, isoCode);
    if (phoneError != null) {
      setState(() => _inlineError = phoneError);
      return;
    }

    final fullPhone = Validators.formatE164(
      '+${_selectedCountry.phoneCode}',
      localDigits,
    );

    setState(() => _sending = true);
    final registered =
        await ref.read(authRepositoryProvider).isPhoneRegistered(fullPhone);
    if (!mounted) return;

    switch (registered) {
      case Success(:final value):
        if (!value) {
          setState(() {
            _sending = false;
            _inlineError = strings.phoneNotRegistered;
          });
          return;
        }
      case Failure(:final message):
        setState(() {
          _sending = false;
          _inlineError = message;
        });
        return;
    }

    final sendResult =
        await ref.read(authRepositoryProvider).sendWhatsAppOtp(
              fullPhone,
              purpose: 'password_reset',
            );
    if (!mounted) return;
    setState(() => _sending = false);

    switch (sendResult) {
      case Success():
        context.push(
          '${AppRoutes.phoneVerify}?phone=${Uri.encodeComponent(fullPhone)}&purpose=password_reset',
        );
      case Failure(:final message):
        setState(() => _inlineError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthDarkHeader(
            title: strings.forgotPassword,
            subtitle: strings.chooseRecoveryMethod,
            leading: AppBackButton(onPressed: _goBack),
              logo: const AuthHeaderLogo(),
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
                    _RecoveryOptionCard(
                      selected: _selectedMethod == _RecoveryMethod.email,
                      icon: Icons.email_outlined,
                      label: strings.continueViaEmail,
                      sublabel: strings.linkedEmailHint,
                      onTap: () {
                        setState(() {
                          _selectedMethod = _RecoveryMethod.email;
                          _inlineError = null;
                        });
                      },
                    ),
                    if (_phoneRecoveryEnabled) ...[
                      const SizedBox(height: 12),
                      _RecoveryOptionCard(
                        selected: _selectedMethod == _RecoveryMethod.phone,
                        icon: Icons.phone_outlined,
                        label: strings.continueViaPhone,
                        sublabel: strings.linkedPhoneHint,
                        onTap: () {
                          setState(() {
                            _selectedMethod = _RecoveryMethod.phone;
                            _inlineError = null;
                          });
                        },
                      ),
                    ],
                    if (_selectedMethod == _RecoveryMethod.email) ...[
                      const SizedBox(height: 20),
                      AuthPillField(
                        label: strings.emailLabel,
                        controller: _emailController,
                        hintText: 'example@email.com',
                        keyboardType: TextInputType.emailAddress,
                        grouped: false,
                        loginStyle: true,
                        onChanged: (_) {
                          if (_inlineError != null) {
                            setState(() => _inlineError = null);
                          }
                        },
                      ),
                    ],
                    if (_selectedMethod == _RecoveryMethod.phone) ...[
                      const SizedBox(height: 20),
                      Text(
                        strings.phoneNumber,
                        style: AppFonts.sans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.pureWhite.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _ForgotPasswordPhoneField(
                        controller: _phoneController,
                        country: _selectedCountry,
                        enabled: !_sending,
                        onPickCountry: _pickCountry,
                        onChanged: (_) {
                          if (_inlineError != null) {
                            setState(() => _inlineError = null);
                          }
                        },
                      ),
                    ],
                    if (_inlineError != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        _inlineError!,
                        style: AppFonts.sans(
                          fontSize: 13,
                          color: AppColors.rejected,
                        ),
                      ),
                    ],
                    const SizedBox(height: 28),
                    AuthPrimaryButton(
                      label: strings.sendAction,
                      loading: _sending,
                      loginStyle: true,
                      onPressed: _sending ? null : _onSendPressed,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _ForgotPasswordPhoneField extends StatelessWidget {
  const _ForgotPasswordPhoneField({
    required this.controller,
    required this.country,
    required this.enabled,
    required this.onPickCountry,
    required this.onChanged,
  });

  final TextEditingController controller;
  final Country country;
  final bool enabled;
  final VoidCallback onPickCountry;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x15FFFFFF)),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: enabled ? onPickCountry : null,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Text(country.flagEmoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 6),
                    Text(
                      '+${country.phoneCode}',
                      style: AppFonts.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.pureWhite.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: 1,
            height: 28,
            color: const Color(0x15FFFFFF),
          ),
          Expanded(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.phone,
                enabled: enabled,
                cursorColor: AppColors.volt,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.pureWhite,
                ),
                decoration: AuthFormStyles.loginFieldDecoration(
                  hintText: '7XXXXXXXXX',
                ).copyWith(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecoveryOptionCard extends StatelessWidget {
  const _RecoveryOptionCard({
    required this.selected,
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.volt : const Color(0x15FFFFFF),
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 68,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: selected ? AppColors.volt : AppColors.pureWhite,
                  size: 22,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: AppFonts.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pureWhite,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        sublabel,
                        style: AppFonts.sans(
                          fontSize: 12,
                          color: AppColors.pureWhite.withValues(alpha: 0.55),
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                _RecoveryRadio(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryRadio extends StatelessWidget {
  const _RecoveryRadio({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? AppColors.volt : Colors.transparent,
        border: Border.all(
          color: selected ? AppColors.volt : AppColors.pureWhite.withValues(alpha: 0.35),
          width: 2,
        ),
      ),
      child: selected
          ? Center(
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.canvas,
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
