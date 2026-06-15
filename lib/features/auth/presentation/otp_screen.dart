import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/auth_navigation.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_form_styles.dart';
import '../widgets/auth_hero_header.dart';
import '../widgets/otp_input.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpInputKey = GlobalKey<OtpInputState>();
  String _otpCode = '';

  Future<void> _verify() async {
    if (_otpCode.length != OtpInputState.length) return;

    final result = await ref.read(authNotifierProvider.notifier).verifyOTP(
          phone: widget.phone,
          otp: _otpCode,
        );

    if (!mounted) return;

    switch (result) {
      case Success():
        final route = await resolvePostAuthRoute(ref);
        if (mounted) context.go(route);
      case Failure():
        _otpInputKey.currentState?.clear();
        setState(() => _otpCode = '');
    }
  }

  Future<void> _resend() async {
    final countdown = ref.read(_otpCountdownProvider);
    if (countdown > 0) return;

    final result =
        await ref.read(authNotifierProvider.notifier).sendOTP(widget.phone);
    if (!mounted) return;

    switch (result) {
      case Success():
        ref.read(_otpCountdownProvider.notifier).restart();
        _otpInputKey.currentState?.clear();
        setState(() => _otpCode = '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(appLocalizationsProvider).newOtpSent)),
        );
      case Failure(:final message):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
    }
  }

  void _goBack() {
    ref.read(authNotifierProvider.notifier).cancelOtpFlow();
    context.go(AppRoutes.phone);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final auth = ref.watch(authNotifierProvider);
    final countdown = ref.watch(_otpCountdownProvider);
    final verifying = auth.status == AuthFlowStatus.loading;
    final canVerify = _otpCode.length == OtpInputState.length && !verifying;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthHeroHeader(
                title: strings.verifyOtp,
                subtitle: 'أرسلنا رمزاً إلى\n${widget.phone}',
                leading: IconButton(
                  onPressed: verifying ? null : _goBack,
                  icon: const Icon(Icons.arrow_forward_ios_rounded),
                  color: Colors.white,
                  iconSize: 20,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OtpInput(
                        key: _otpInputKey,
                        enabled: !verifying,
                        onChanged: (code) {
                          if (_otpCode != code) {
                            setState(() => _otpCode = code);
                          }
                        },
                      ),
                      if (auth.errorMessage != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          auth.errorMessage!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      AuthPrimaryButton(
                        label: strings.confirmOtp,
                        loading: verifying,
                        onPressed: canVerify ? _verify : null,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        countdown > 0
                            ? 'إعادة الإرسال خلال $countdown ث'
                            : 'يمكنك إعادة إرسال الرمز',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: countdown > 0 || verifying ? null : _resend,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                            foregroundColor: AppColors.primary,
                            side: BorderSide(
                              color: AppColors.borderLight.withValues(alpha: 0.9),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AuthFormStyles.pillRadius,
                              ),
                            ),
                          ),
                          child: Text(
                            strings.resendOtp,
                            style: GoogleFonts.cairo(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _OtpHelpCard(phone: widget.phone),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (verifying)
            ColoredBox(
              color: const Color(0x88000000),
              child: LoadingWidget(message: strings.loading),
            ),
        ],
      ),
    );
  }
}

class _OtpCountdownNotifier extends Notifier<int> {
  Timer? _timer;

  @override
  int build() {
    ref.onDispose(() => _timer?.cancel());
    _start();
    return 60;
  }

  void _start() {
    _timer?.cancel();
    state = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state <= 1) {
        timer.cancel();
        state = 0;
      } else {
        state = state - 1;
      }
    });
  }

  void restart() => _start();
}

final _otpCountdownProvider =
    NotifierProvider.autoDispose<_OtpCountdownNotifier, int>(
  _OtpCountdownNotifier.new,
);

class _OtpHelpCard extends StatelessWidget {
  const _OtpHelpCard({required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AuthFormStyles.fieldFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'لم يصلك الرمز؟',
            style: GoogleFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '• تأكد أن الرقم $phone صحيح\n'
            '• انتظر حتى دقيقة — قد يتأخر SMS\n'
            '• Twilio: أضف رقمك في Sender Pool لخدمة souqiq-otp\n'
            '• يجب تفعيل مزود SMS (Twilio أو MessageBird) في Supabase\n'
            '• للتطوير: أضف رقمك كـ Test OTP في لوحة Supabase\n'
            '• راجع supabase/README.md — قسم Phone OTP',
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textMuted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
