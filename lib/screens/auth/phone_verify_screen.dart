import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/router/app_router.dart';
import '../../core/utils/auth_navigation.dart';
import '../../core/utils/result.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../shared/widgets/app_back_button.dart';
import 'widgets/otp_four_box_input.dart';

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
  int _secondsLeft = 60;
  bool _verifying = false;

  @override
  void initState() {
    super.initState();
    _otpController.addListener(() => setState(() {}));
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() => _secondsLeft = 0);
      } else {
        setState(() => _secondsLeft -= 1);
      }
    });
  }

  Future<void> _resend() async {
    final result = await ref.read(authRepositoryProvider).resendWhatsAppOtp(
          widget.phone,
          purpose: widget.purpose,
        );
    if (!mounted) return;
    switch (result) {
      case Success():
        _otpKey.currentState?.clear();
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

  Future<void> _verify() async {
    final code = _otpController.text;
    if (code.length != OtpFourBoxInputState.length) return;

    setState(() => _verifying = true);
    final result =
        await ref.read(authNotifierProvider.notifier).verifyWhatsAppOtp(
              phone: widget.phone,
              otp: code,
              purpose: widget.purpose,
            );
    if (!mounted) return;
    setState(() => _verifying = false);

    switch (result) {
      case Success():
        if (widget.purpose == 'password_reset') {
          if (mounted) context.go(AppRoutes.resetPassword);
          return;
        }
        final route = await resolvePostAuthRoute(ref);
        if (mounted) context.go(route);
      case Failure():
        await _otpKey.currentState?.shake();
        _otpKey.currentState?.clear();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'رمز غير صحيح',
              style: AppFonts.cairo(fontWeight: FontWeight.w600),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canVerify =
        _otpController.text.length == OtpFourBoxInputState.length && !_verifying;

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
            'التحقق من الرقم',
            style: AppFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF111111),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'أدخل الرمز الذي أرسلناه إلى',
                style: AppFonts.cairo(
                  fontSize: 14,
                  color: const Color(0xFF888888),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                widget.phone,
                style: AppFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 32),
              OtpFourBoxInput(
                key: _otpKey,
                controller: _otpController,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.message_rounded,
                    size: 16,
                    color: Color(0xFF25D366),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'تم إرسال الرمز عبر واتساب إلى ${widget.phone}',
                      textAlign: TextAlign.center,
                      style: AppFonts.cairo(
                        fontSize: 12,
                        color: const Color(0xFF888888),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (_secondsLeft > 0)
                Text(
                  '00:${_secondsLeft.toString().padLeft(2, '0')}',
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFF5A623),
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
                  onPressed: canVerify ? _verify : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
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
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          'التحقق',
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
