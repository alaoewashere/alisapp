import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/auth_navigation.dart';
import '../../core/utils/result.dart';
import '../../features/auth/providers/auth_provider.dart';
import 'widgets/otp_four_box_input.dart';
import 'widgets/otp_success_dialog.dart';

class PhoneVerifyScreen extends ConsumerStatefulWidget {
  const PhoneVerifyScreen({
    super.key,
    required this.phone,
    this.purpose,
  });

  final String phone;
  final String? purpose;

  @override
  ConsumerState<PhoneVerifyScreen> createState() => _PhoneVerifyScreenState();
}

class _PhoneVerifyScreenState extends ConsumerState<PhoneVerifyScreen> {
  final _otpController = TextEditingController();
  final _otpKey = GlobalKey<OtpFourBoxInputState>();
  Timer? _timer;
  int _secondsLeft = 45;
  bool _verifying = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(_onOtpChanged);
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.removeListener(_onOtpChanged);
    _otpController.dispose();
    super.dispose();
  }

  void _onOtpChanged() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    } else {
      setState(() {});
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        if (mounted) setState(() => _secondsLeft = 0);
      } else if (mounted) {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _resend() async {
    if (_secondsLeft > 0 || _verifying) return;

    final strings = ref.read(appLocalizationsProvider);
    final result = await ref.read(authRepositoryProvider).resendWhatsAppOtp(
          widget.phone,
          purpose: widget.purpose,
        );
    if (!mounted) return;

    switch (result) {
      case Success():
        _otpKey.currentState?.clear();
        setState(() => _errorMessage = null);
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(strings.newOtpSent)),
        );
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  Future<void> _navigateAfterSuccess() async {
    if (widget.purpose == 'password_reset') {
      if (mounted) context.go(AppRoutes.resetPassword);
      return;
    }
    final route = await resolvePostAuthRoute(ref);
    if (mounted) context.go(route);
  }

  Future<void> _verify() async {
    final code = _otpController.text;
    if (code.length != 4 || _verifying) return;

    setState(() {
      _verifying = true;
      _errorMessage = null;
    });

    final result =
        await ref.read(authNotifierProvider.notifier).verifyWhatsAppOtp(
              phone: widget.phone,
              otp: code,
              purpose: widget.purpose,
            );

    if (!mounted) return;

    switch (result) {
      case Success():
        await showOtpSuccessThenContinue(context);
        if (!mounted) return;
        setState(() => _verifying = false);
        await _navigateAfterSuccess();
      case Failure():
        setState(() {
          _verifying = false;
          _errorMessage = ref.read(appLocalizationsProvider).otpInvalidCode;
        });
        await _otpKey.currentState?.shake();
        _otpKey.currentState?.clear();
    }
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final canVerify =
        _otpController.text.length == 4 && !_verifying;
    final resendActive = _secondsLeft == 0 && !_verifying;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.canvas,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: _verifying ? null : () => context.pop(),
          icon: const Icon(Icons.arrow_back, color: AppColors.pureWhite),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 56,
                      color: AppColors.volt,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      strings.verifyOtp,
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.pureWhite,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      strings.otpSentViaWhatsapp,
                      textAlign: TextAlign.center,
                      style: AppFonts.sans(
                        fontSize: 14,
                        color: AppColors.pureWhite.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.phone,
                      textAlign: TextAlign.center,
                      textDirection: TextDirection.ltr,
                      style: AppFonts.sans(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.volt,
                      ),
                    ),
                    const SizedBox(height: 36),
                    OtpFourBoxInput(
                      key: _otpKey,
                      controller: _otpController,
                      enabled: !_verifying,
                    ),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppFonts.sans(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (_secondsLeft > 0)
                      Text(
                        _timerLabel,
                        textDirection: TextDirection.ltr,
                        style: AppFonts.sans(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.volt,
                        ),
                      ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: resendActive ? _resend : null,
                      child: Text(
                        strings.otpResendCode,
                        textAlign: TextAlign.center,
                        style: AppFonts.sans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: resendActive
                              ? AppColors.volt
                              : AppColors.pureWhite.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: canVerify ? _verify : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: canVerify
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
                        child: _verifying
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.canvas,
                                ),
                              )
                            : Text(
                                strings.otpVerifyButton,
                                style: AppFonts.sans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.canvas,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
