import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';

Future<bool> showPriceChangeConfirmDialog(BuildContext context) async {
  final strings = context.l10n;
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          strings.priceChangeTitle,
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          strings.priceChangeWarning,
          style: AppFonts.cairo(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(strings.cancel, style: AppFonts.cairo()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              strings.confirmChange,
              style: AppFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
