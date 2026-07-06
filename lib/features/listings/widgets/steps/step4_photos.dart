import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/l10n/l10n_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/models/listing_model.dart';
import '../../providers/post_listing_provider.dart';
import '../image_picker_grid.dart';

class Step4Photos extends ConsumerWidget {
  const Step4Photos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final strings = ref.watch(appLocalizationsProvider);
    final hasPhotos = state.images.isNotEmpty;
    final isProOrPremium = state.listingPackage == ListingPackage.pro ||
        state.listingPackage == ListingPackage.premium;
    final effectiveMax = isProOrPremium ? 15 : AppConstants.maxListingPhotos;
    final maxPhotos = effectiveMax.toString();

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
                    strings.photosTitle,
                    style: AppFonts.sans(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.photosSubtitle(maxPhotos),
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
                      strings.firstPhotoIsCover,
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
              maxImages: effectiveMax,
              onAdd: notifier.addImage,
              onAddBatch: notifier.addImages,
              onRemove: notifier.removeImage,
              onReorder: notifier.reorderImages,
              onLimitReached: () {
                final limitMsg = strings.maxPhotosLimit(maxPhotos);
                final upgradeHint = isProOrPremium
                    ? limitMsg
                    : '$limitMsg — اختر باقة برو للحصول على 15 صورة';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      upgradeHint,
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
                strings.noPhotosYet,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 15,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                strings.photosHelpSell,
                textAlign: TextAlign.center,
                style: AppFonts.sans(
                  fontSize: 12,
                  color: AppColors.textMuted.withValues(alpha: 0.75),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _PhotoTipsCard(strings: strings),
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
  const _PhotoTipsCard({required this.strings});

  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Expanded(
            child: _PhotoTip(Icons.wb_sunny_outlined, strings.photoTipGoodLight),
          ),
          const _TipDivider(),
          Expanded(
            child: _PhotoTip(Icons.crop_free, strings.photoTipClearPhotos),
          ),
          const _TipDivider(),
          Expanded(
            child: _PhotoTip(
              Icons.photo_size_select_large,
              strings.photoTipMultipleAngles,
            ),
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
