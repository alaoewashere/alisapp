import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/video_utils.dart';
import '../../../services/video_service.dart';
import '../providers/post_listing_provider.dart';

class ListingVideoUploadSection extends ConsumerWidget {
  const ListingVideoUploadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final canUpload = state.listingPackage.allowsListingVideo;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Opacity(
        opacity: canUpload ? 1 : 0.55,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.fieldCarbon,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    canUpload ? Icons.videocam_outlined : Icons.lock_outline,
                    color: canUpload ? AppColors.volt : AppColors.premiumGold,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'أضف فيديو توضيحي (حتى 60 ثانية)',
                      style: AppFonts.sans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.pureWhite,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                canUpload
                    ? 'متاح لمشتركي Pro و Premium فقط'
                    : 'ترقّ إلى Pro 🔒',
                style: AppFonts.sans(
                  fontSize: 12,
                  color: canUpload
                      ? AppColors.textMuted
                      : AppColors.premiumGold.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: 14),
              if (state.isVideoProcessing) ...[
                LinearProgressIndicator(
                  value: state.videoProcessingProgress,
                  backgroundColor: AppColors.borderLight,
                  color: AppColors.volt,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري معالجة الفيديو... ${(state.videoProcessingProgress * 100).round()}%',
                  textAlign: TextAlign.center,
                  style: AppFonts.cairo(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ] else if (state.pendingVideoFile != null &&
                  state.pendingVideoThumbnail != null) ...[
                _VideoPreview(
                  thumbnail: state.pendingVideoThumbnail!,
                  durationLabel: state.videoDurationSeconds != null
                      ? formatVideoDuration(state.videoDurationSeconds!)
                      : '--:--',
                  onRemove: notifier.removeVideo,
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: canUpload
                      ? () => _pickVideo(context, ref, ImageSource.gallery)
                      : () => notifier.goToStep(state.packageStep),
                  icon: Icon(canUpload ? Icons.video_library_outlined : Icons.lock),
                  label: Text(canUpload ? 'اختر فيديو' : 'ترقّ إلى Pro 🔒'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: canUpload ? AppColors.volt : AppColors.premiumGold,
                    side: BorderSide(
                      color: canUpload
                          ? AppColors.volt.withValues(alpha: 0.45)
                          : AppColors.borderLight,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                if (canUpload) ...[
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () => _pickVideo(context, ref, ImageSource.camera),
                    icon: const Icon(Icons.videocam, size: 18),
                    label: const Text('تسجيل فيديو'),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickVideo(
    BuildContext context,
    WidgetRef ref,
    ImageSource source,
  ) async {
    final picked = await ImagePicker().pickVideo(
      source: source,
      maxDuration: const Duration(seconds: 90),
    );
    if (picked == null || !context.mounted) return;

    final file = File(picked.path);
    try {
      await ref.read(postListingProvider.notifier).setPendingVideo(file);
    } on VideoUploadException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message)),
        );
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر معالجة الفيديو')),
        );
      }
    }
  }
}

class _VideoPreview extends StatelessWidget {
  const _VideoPreview({
    required this.thumbnail,
    required this.durationLabel,
    required this.onRemove,
  });

  final File thumbnail;
  final String durationLabel;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(thumbnail, fit: BoxFit.cover),
          ),
          Center(
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.volt.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.play_arrow_rounded,
                color: AppColors.canvas,
                size: 32,
              ),
            ),
          ),
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                durationLabel,
                style: AppFonts.inter(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          Positioned(
            top: 6,
            left: 6,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onRemove,
                child: const Padding(
                  padding: EdgeInsets.all(6),
                  child: Icon(Icons.close, color: Colors.white, size: 18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
