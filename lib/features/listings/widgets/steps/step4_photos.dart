import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

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
      color: Colors.white,
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
                    style: GoogleFonts.cairo(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF111111),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'أضف حتى ${AppConstants.maxListingPhotos} صور — اسحب لإعادة الترتيب',
                    style: GoogleFonts.cairo(
                      fontSize: 13,
                      color: const Color(0xFF888888),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'الصورة الأولى هي الغلاف',
                      style: GoogleFonts.cairo(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
                      style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
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
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 12),
              Text(
                'لم تضف أي صور بعد',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 15,
                  color: const Color(0xFFBBBBBB),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'الصور تزيد من فرصة بيع إعلانك',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 12,
                  color: const Color(0xFFCCCCCC),
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
                  style: GoogleFonts.cairo(
                    color: Theme.of(context).colorScheme.error,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFFF0F0F0)),
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
      margin: EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFEEEEEE),
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
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.cairo(
            fontSize: 11,
            color: const Color(0xFF555555),
            height: 1.2,
          ),
        ),
      ],
    );
  }
}
