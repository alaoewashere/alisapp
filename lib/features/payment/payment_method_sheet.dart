import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';

/// Shows the payment method picker (ZainCash live; Qi Card and
/// Visa/Mastercard shown as "قريباً" until real card-processor merchant
/// accounts exist for them — there is nowhere for a card-details page to
/// actually send a charge yet, so it isn't built).
///
/// Returns `true` if the user picked ZainCash (the only enabled option),
/// or `false` if they dismissed the sheet without choosing anything.
Future<bool> showPaymentMethodSheet(BuildContext context) async {
  final selected = await showModalBottomSheet<bool>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Text(
                'اختر طريقة الدفع',
                style: AppFonts.cairo(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ),
            const SizedBox(height: 16),
            PaymentMethodTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'ZainCash',
              subtitle: 'محفظة زين كاش',
              onTap: () => Navigator.of(ctx).pop(true),
            ),
            const SizedBox(height: 10),
            const PaymentMethodTile(
              icon: Icons.credit_card,
              title: 'بطاقة كي (Qi Card)',
              subtitle: 'قريباً',
              enabled: false,
            ),
            const SizedBox(height: 10),
            const PaymentMethodTile(
              icon: Icons.payment,
              title: 'Visa / Mastercard',
              subtitle: 'قريباً',
              enabled: false,
            ),
          ],
        ),
      ),
    ),
  );
  return selected ?? false;
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final color = enabled ? AppColors.textDark : AppColors.textMuted;
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? onTap : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.6,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppFonts.cairo(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: AppFonts.cairo(
                          fontSize: 12,
                          color: const Color(0xFF888888),
                        ),
                      ),
                    ],
                  ),
                ),
                if (enabled)
                  const Icon(Icons.chevron_left, color: Color(0xFFBBBBBB))
                else
                  const Icon(Icons.lock_outline,
                      color: Color(0xFFBBBBBB), size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
