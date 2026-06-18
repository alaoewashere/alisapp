import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/verification_constants.dart';
import '../../core/router/app_router.dart';
import '../../shared/widgets/sello_app_bar.dart';

/// Screen 2 — pick document type.
class VerificationDocumentTypeScreen extends StatelessWidget {
  const VerificationDocumentTypeScreen({super.key});

  static const _documentTypes = [
    (
      type: VerificationDocumentType.nationalId,
      label: 'الهوية الوطنية',
      icon: Icons.badge_outlined,
    ),
    (
      type: VerificationDocumentType.driversLicense,
      label: 'رخصة القيادة',
      icon: Icons.directions_car_outlined,
    ),
    (
      type: VerificationDocumentType.passport,
      label: 'جواز السفر',
      icon: Icons.menu_book_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SelloAppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'اختر نوع الوثيقة',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (var i = 0; i < _documentTypes.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _DocumentTypeTile(
                key: ValueKey(_documentTypes[i].type),
                label: _documentTypes[i].label,
                icon: _documentTypes[i].icon,
                onTap: () => context.push(
                  '${AppRoutes.verificationUpload}?type=${_documentTypes[i].type}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DocumentTypeTile extends StatelessWidget {
  static const _cardBorder = Color(0x15FFFFFF);

  const _DocumentTypeTile({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.fieldCarbon,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _cardBorder, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.chevron_left, color: AppColors.textMuted),
              const Spacer(),
              Text(
                label,
                style: AppFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.volt, size: 26),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _cardBorder,
                    width: 2,
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
