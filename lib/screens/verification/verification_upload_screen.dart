import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/verification_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/supabase/supabase_client.dart';
import '../../features/auth/widgets/auth_form_styles.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../features/verification/data/verification_repository.dart';
import '../../shared/widgets/sello_app_bar.dart';

/// Screen 3 — capture and upload ID images.
class VerificationUploadScreen extends ConsumerStatefulWidget {
  const VerificationUploadScreen({super.key, required this.documentType});

  final String documentType;

  @override
  ConsumerState<VerificationUploadScreen> createState() =>
      _VerificationUploadScreenState();
}

class _VerificationUploadScreenState
    extends ConsumerState<VerificationUploadScreen> {
  final _picker = ImagePicker();
  File? _frontImage;
  File? _backImage;
  bool _submitting = false;

  bool get _needsBack =>
      VerificationDocumentType.requiresBackImage(widget.documentType);

  Future<void> _pickImage({required bool isBack}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('التقاط صورة'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('اختيار من المعرض'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 2000,
    );
    if (picked == null || !mounted) return;

    setState(() {
      if (isBack) {
        _backImage = File(picked.path);
      } else {
        _frontImage = File(picked.path);
      }
    });
  }

  Future<void> _submit() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null || _frontImage == null) return;
    if (_needsBack && _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تصوير الوجه الخلفي للوثيقة',
            style: AppFonts.cairo(),
          ),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final repo = ref.read(verificationRepositoryProvider);
      final frontPath = await repo.uploadDocumentImage(
        userId: userId,
        file: _frontImage!,
        suffix: 'front',
      );
      String? backPath;
      if (_needsBack && _backImage != null) {
        backPath = await repo.uploadDocumentImage(
          userId: userId,
          file: _backImage!,
          suffix: 'back',
        );
      }

      await repo.submitVerificationRequest(
        userId: userId,
        documentType: widget.documentType,
        frontImagePath: frontPath,
        backImagePath: backPath,
      );

      ref.invalidate(myProfileProvider);

      if (!mounted) return;
      context.go(AppRoutes.verificationSuccess);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تعذّر إرسال الطلب، حاول مرة أخرى',
            style: AppFonts.cairo(),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit =
        _frontImage != null && (!_needsBack || _backImage != null);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SelloAppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'صوّر الوثيقة',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              VerificationDocumentType.labelAr(widget.documentType),
              style: AppFonts.cairo(
                fontSize: 14,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            _UploadFrame(
              label: 'الوجه الأمامي',
              image: _frontImage,
              onCapture: () => _pickImage(isBack: false),
            ),
            if (_needsBack) ...[
              const SizedBox(height: 16),
              _UploadFrame(
                label: 'الوجه الخلفي',
                image: _backImage,
                onCapture: () => _pickImage(isBack: true),
              ),
            ],
            const SizedBox(height: 24),
            AuthPrimaryButton(
              label: 'إرسال للمراجعة',
              loading: _submitting,
              loginStyle: true,
              onPressed: canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _UploadFrame extends StatelessWidget {
  static const _frameBorder = Color(0x15FFFFFF);

  const _UploadFrame({
    required this.label,
    required this.image,
    required this.onCapture,
  });

  final String label;
  final File? image;
  final VoidCallback onCapture;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: AppFonts.cairo(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.pureWhite,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onCapture,
          child: AspectRatio(
            aspectRatio: 1.58,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.fieldCarbon,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _frameBorder,
                  width: 1,
                ),
              ),
              child: image != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(image!, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.approved,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.photo_camera_outlined,
                          size: 40,
                          color: AppColors.volt,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'التقاط صورة',
                          style: AppFonts.cairo(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.pureWhite,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
