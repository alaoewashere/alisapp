import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:my_app/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/sello_app_bar.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/edit_listing_form_mode.dart';
import '../providers/edit_listing_provider.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/edit_listing_photos_section.dart';
import '../widgets/edit_listing_video_section.dart';
import '../widgets/price_change_confirm_dialog.dart';
import '../widgets/steps/step2_details.dart';
import '../widgets/steps/step3_location.dart';
import '../widgets/steps/step_contact_preferences.dart';

class EditListingScreen extends ConsumerStatefulWidget {
  const EditListingScreen({super.key, required this.listingId});

  final String listingId;

  @override
  ConsumerState<EditListingScreen> createState() => _EditListingScreenState();
}

class _EditListingScreenState extends ConsumerState<EditListingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(isEditListingFormProvider.notifier).setEnabled(true);
      }
    });
  }

  @override
  void dispose() {
    ref.read(isEditListingFormProvider.notifier).setEnabled(false);
    super.dispose();
  }

  Future<void> _save() async {
    final edit = ref.read(editListingProvider(widget.listingId));
    final post = ref.read(postListingProvider);
    final newPrice = (post.price ?? 0).round();
    final loadedPrice = (edit.loadedPrice ?? post.price ?? 0).round();

    if (loadedPrice != newPrice) {
      final confirmed = await showPriceChangeConfirmDialog(context);
      if (!confirmed || !mounted) return;
    }

    final ok =
        await ref.read(editListingProvider(widget.listingId).notifier).save();

    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم حفظ التعديلات ✓',
            style: AppFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      final validationError = ref.read(postListingProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            validationError ?? 'حدث خطأ، حاول مرة أخرى',
            style: AppFonts.cairo(),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = ref.watch(editListingProvider(widget.listingId));
    final post = ref.watch(postListingProvider);

    if (edit.loading && !edit.loaded) {
      return const Scaffold(body: LoadingWidget(message: 'جاري التحميل...'));
    }

    if (edit.error != null && !edit.loaded) {
      return Scaffold(
        appBar: SelloAppBar(title: const Text('تعديل الإعلان')),
        body: AppErrorWidget(
          message: edit.error!,
          onRetry: () => ref.invalidate(editListingProvider(widget.listingId)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          'تعديل الإعلان',
          style: AppFonts.cairo(fontWeight: FontWeight.bold),
        ),
        leading: AppBackButton(
          onPressed: edit.loading
              ? null
              : () {
                  ref.read(postListingProvider.notifier).reset();
                  context.pop();
                },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (post.categoryPath.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: _ReadOnlyCategoryBanner(path: post.categoryPath),
                    ),
                  const Step2Details(),
                  const Step3Location(),
                  const StepContactPreferences(),
                  EditListingPhotosSection(listingId: widget.listingId),
                  EditListingVideoSection(
                    existingVideoUrl: edit.existingVideoUrl,
                    existingThumbnailUrl: edit.existingVideoThumbnailUrl,
                    canUploadVideo: edit.canUploadVideo,
                  ),
                  if (post.error != null)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        post.error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: edit.loading ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: edit.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'حفظ التعديلات',
                        style: AppFonts.cairo(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadOnlyCategoryBanner extends StatelessWidget {
  const _ReadOnlyCategoryBanner({required this.path});

  final List<CategoryModel> path;

  @override
  Widget build(BuildContext context) {
    final labels = path.map((c) => c.nameAr).join(' > ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الفئة',
            style: AppFonts.cairo(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            labels,
            style: AppFonts.cairo(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }
}
