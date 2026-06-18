import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/result.dart';
import '../../features/auth/widgets/otp_input.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../features/profile/data/profile_repository.dart';

class ProfilePhoneOtpScreen extends ConsumerStatefulWidget {
  const ProfilePhoneOtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<ProfilePhoneOtpScreen> createState() =>
      _ProfilePhoneOtpScreenState();
}

class _ProfilePhoneOtpScreenState extends ConsumerState<ProfilePhoneOtpScreen> {
  final _otpKey = GlobalKey<OtpInputState>();
  String _otp = '';
  String? _inlineError;
  Timer? _timer;
  int _secondsLeft = 600;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsLeft = 600;
      _inlineError = null;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  String get _timerLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Future<void> _resend() async {
    final result = await ref
        .read(profileRepositoryProvider)
        .sendProfilePhoneOtp(widget.phone);
    if (!mounted) return;
    switch (result) {
      case Success():
        _otpKey.currentState?.clear();
        setState(() => _otp = '');
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم إرسال رمز جديد',
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

  Future<void> _confirm() async {
    if (_otp.length != OtpInputState.length) return;

    setState(() {
      _verifying = true;
      _inlineError = null;
    });

    final result = await ref.read(profileRepositoryProvider).verifyProfilePhoneOtp(
          phoneE164: widget.phone,
          otp: _otp,
        );

    if (!mounted) return;
    setState(() => _verifying = false);

    switch (result) {
      case Success():
        ref.invalidate(currentProfileProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تم التحقق من رقم الهاتف بنجاح',
              style: AppFonts.cairo(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.green,
          ),
        );
        context.pop(true);
      case Failure(:final message):
        setState(() => _inlineError = message);
        _otpKey.currentState?.clear();
        setState(() => _otp = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final canConfirm =
        _otp.length == OtpInputState.length && !_verifying;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: AppBackButton(
            onPressed: _verifying ? null : () => context.pop(),
          ),
          title: Text(
            'أدخل رمز التحقق',
            style: AppFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(
                'تم إرسال رمز مكون من 6 أرقام عبر واتساب إلى',
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  widget.phone,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              OtpInput(
                key: _otpKey,
                enabled: !_verifying,
                onChanged: (value) {
                  setState(() {
                    _otp = value;
                    if (_inlineError != null) _inlineError = null;
                  });
                },
              ),
              if (_inlineError != null) ...[
                const SizedBox(height: 12),
                Text(
                  _inlineError!,
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              if (_secondsLeft > 0)
                Text(
                  _timerLabel,
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                )
              else
                TextButton(
                  onPressed: _verifying ? null : _resend,
                  child: Text(
                    'إعادة الإرسال',
                    style: AppFonts.cairo(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: canConfirm ? _confirm : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.canvas,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
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
                          'تأكيد',
                          style: AppFonts.cairo(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
