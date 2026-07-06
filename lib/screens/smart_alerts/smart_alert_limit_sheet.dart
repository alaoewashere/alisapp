import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/constants/app_colors.dart';

Future<void> showSmartAlertLimitSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.fieldCarbon,
    builder: (context) {
      final strings = context.l10n;
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.notifications_off_outlined,
                size: 48,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 12),
              Text(
                strings.alertLimitFreeReached,
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.upgradeProUnlimitedAlerts,
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 14,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(strings.understood, style: AppFonts.cairo()),
              ),
            ],
          ),
        ),
      );
    },
  );
}
