import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/result.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/auth_provider.dart';
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
      case Success(:final value):
        if (value.isNewUser) {
          context.go(AppRoutes.profileSetup);
        } else {
          context.go(AppRoutes.home);
        }
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

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final auth = ref.watch(authNotifierProvider);
    final countdown = ref.watch(_otpCountdownProvider);
    final verifying = auth.status == AuthFlowStatus.loading;
    final canVerify = _otpCode.length == OtpInputState.length && !verifying;

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: verifying
              ? null
              : () {
                  ref.read(authNotifierProvider.notifier).cancelOtpFlow();
                  context.go(AppRoutes.phone);
                },
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  strings.verifyOtp,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'أرسلنا رمزاً إلى\n${widget.phone}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
                const SizedBox(height: 40),
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
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 32),
                CustomButton(
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
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: countdown > 0 || verifying ? null : _resend,
                  child: Text(strings.resendOtp),
                ),
                const SizedBox(height: 24),
                _OtpHelpCard(phone: widget.phone),
              ],
            ),
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
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'لم يصلك الرمز؟',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
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
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
