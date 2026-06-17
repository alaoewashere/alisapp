import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../providers/post_listing_provider.dart';
import '../image_picker_grid.dart';
import '../listing_video_upload_section.dart';

class Step4Photos extends ConsumerWidget {
  const Step4Photos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final hasPhotos = state.images.isNotEmpty;

    return ColoredBox(
      color: AppColors.canvas,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصور',
                    style: AppFonts.sans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أضف حتى ${AppConstants.maxListingPhotos} صور — اسحب لإعادة الترتيب',
                    style: AppFonts.sans(
                      fontSize: 13,
                      color: AppColors.pureWhite.withValues(alpha: 0.6),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.volt,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'الصورة الأولى هي الغلاف',
                      style: AppFonts.sans(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.canvas,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ImagePickerGrid(
              images: state.images,
              maxImages: AppConstants.maxListingPhotos,
              onAdd: notifier.addImage,
              onAddBatch: notifier.addImages,
              onRemove: notifier.removeImage,
              onReorder: notifier.reorderImages,
              onLimitReached: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'الحد الأقصى ${AppConstants.maxListingPhotos} صور',
                      style: AppFonts.sans(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              },
            ),
            if (!hasPhotos) ...[
              const SizedBox(height: 32),
              Icon(
                Icons.photo_library_outlined,
                size: 64,
                color: AppColors.textMuted.withValues(alpha: 0.45),
              ),
              const SizedBox(height: 12),
              Text(
                'لم تضف أي صور بعد',
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الصور تزيد من فرصة بيع إعلانك',
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.75),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const ListingVideoUploadSection(),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: _PhotoTipsCard(),
            ),
            if (state.error != null) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  state.error!,
                  textAlign: TextAlign.center,
                  style: AppFonts.sans(
                    color: AppColors.rejected,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PhotoTipsCard extends StatelessWidget {
  const _PhotoTipsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: const Row(
        children: [
          Expanded(child: _PhotoTip(Icons.wb_sunny_outlined, 'إضاءة جيدة')),
          _TipDivider(),
          Expanded(child: _PhotoTip(Icons.crop_free, 'صور واضحة')),
          _TipDivider(),
          Expanded(
            child: _PhotoTip(Icons.photo_size_select_large, 'زوايا متعددة'),
          ),
        ],
      ),
    );
  }
}

class _TipDivider extends StatelessWidget {
  const _TipDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.borderLight,
    );
  }
}

class _PhotoTip extends StatelessWidget {
  const _PhotoTip(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: AppColors.textMuted),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: AppFonts.sans(
            fontSize: 11,
            color: AppColors.textMuted,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
