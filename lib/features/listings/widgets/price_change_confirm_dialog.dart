import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'تنبيه: تغيير السعر سيظهر لجميع المشترين في تاريخ السعر',
          style: GoogleFonts.cairo(height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.cairo()),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text(
              'تأكيد التغيير',
              style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );

  return result ?? false;
}
