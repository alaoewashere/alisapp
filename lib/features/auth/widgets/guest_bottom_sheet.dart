import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/navigation_guard.dart';
import '../../../l10n/app_localizations.dart';

const _sheetBackground = Color(0xFF18181A);

Future<void> showGuestBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: _sheetBackground,
    showDragHandle: true,
    builder: (context) {
      final strings = AppLocalizations.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  color: Colors.transparent,
                  child: Image.asset(
                    AppAssets.appLogo,
                    width: 72,
                    height: 72,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                strings.guestSignInPrompt,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                strings.guestSignInBody,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.65),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Deferred: pushing on the same Navigator synchronously
                  // after pop() races the sheet's removal from the page
                  // list — see filter_sheet.dart's _apply() for the full
                  // explanation of the duplicate-key crash this avoids.
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => context.pushGuarded(AppRoutes.phone),
                  );
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.volt,
                  foregroundColor: AppColors.canvas,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  strings.login,
                  style: AppFonts.sans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  strings.cancel,
                  style: AppFonts.sans(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.volt,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
