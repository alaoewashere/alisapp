import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/verification_constants.dart';
import '../../core/router/app_router.dart';

/// Screen 2 — pick document type.
class VerificationDocumentTypeScreen extends StatefulWidget {
  const VerificationDocumentTypeScreen({super.key});

  @override
  State<VerificationDocumentTypeScreen> createState() =>
      _VerificationDocumentTypeScreenState();
}

class _VerificationDocumentTypeScreenState
    extends State<VerificationDocumentTypeScreen> {
  String? _selected;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'اختر نوع الوثيقة',
          style: GoogleFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DocumentTypeTile(
              type: VerificationDocumentType.nationalId,
              label: 'الهوية الوطنية',
              icon: Icons.badge_outlined,
              selected: _selected == VerificationDocumentType.nationalId,
              onTap: () => _goUpload(VerificationDocumentType.nationalId),
            ),
            const SizedBox(height: 12),
            _DocumentTypeTile(
              type: VerificationDocumentType.driversLicense,
              label: 'رخصة القيادة',
              icon: Icons.directions_car_outlined,
              selected: _selected == VerificationDocumentType.driversLicense,
              onTap: () => _goUpload(VerificationDocumentType.driversLicense),
            ),
            const SizedBox(height: 12),
            _DocumentTypeTile(
              type: VerificationDocumentType.passport,
              label: 'جواز السفر',
              icon: Icons.menu_book_outlined,
              selected: _selected == VerificationDocumentType.passport,
              onTap: () => _goUpload(VerificationDocumentType.passport),
            ),
          ],
        ),
      ),
    );
  }

  void _goUpload(String type) {
    setState(() => _selected = type);
    context.push('${AppRoutes.verificationUpload}?type=$type');
  }
}

class _DocumentTypeTile extends StatelessWidget {
  const _DocumentTypeTile({
    required this.type,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String type;
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.borderLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.chevron_left, color: AppColors.textMuted),
              const Spacer(),
              Text(
                label,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 12),
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(width: 12),
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.borderLight,
                    width: 2,
                  ),
                  color: selected
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                child: selected
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
