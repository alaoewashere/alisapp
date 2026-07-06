import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../l10n/app_localizations.dart';

/// Brief success overlay shown after OTP verification before navigation.
Future<void> showOtpSuccessDialog(BuildContext context) {
  final strings = AppLocalizations.of(context);
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return Dialog(
        backgroundColor: AppColors.fieldCarbon,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.volt.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.volt,
                  size: 44,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                strings.otpVerifiedSuccess,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.otpSigningIn,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 14,
                  color: AppColors.pureWhite.withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    },
  );
}

/// Shows the success dialog for [displayDuration], then dismisses it.
Future<void> showOtpSuccessThenContinue(
  BuildContext context, {
  Duration displayDuration = const Duration(milliseconds: 1500),
}) async {
  await showOtpSuccessDialog(context);
  await Future<void>.delayed(displayDuration);
  if (context.mounted) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
