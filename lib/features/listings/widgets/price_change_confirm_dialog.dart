import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';

Future<bool> showPriceChangeConfirmDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'تغيير السعر',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'تنبيه: تغيير السعر سيظهر لجميع المشترين في تاريخ السعر',
          style: AppFonts.cairo(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: AppFonts.cairo()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'تأكيد التغيير',
              style: AppFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
