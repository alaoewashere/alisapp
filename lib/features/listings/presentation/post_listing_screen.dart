import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/moderation/moderation_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/widgets/custom_button.dart';
import '../constants/post_listing_step_labels.dart';
import '../presentation/car_paint_condition_screen.dart';
import '../constants/listing_package_config.dart';
import '../providers/post_listing_provider.dart';
import '../../../shared/widgets/app_back_button.dart';
import '../widgets/listing_publish_success_dialog.dart';
import '../widgets/steps/step1_category.dart';
import '../widgets/steps/step2_details.dart';
import '../widgets/steps/step3_location.dart';
import '../widgets/steps/step4_photos.dart';
import '../widgets/steps/step5_review.dart';
import '../widgets/steps/step_contact_preferences.dart';
import '../widgets/steps/step_listing_package.dart';

class PostListingScreen extends ConsumerWidget {
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        title: Text(postListingStepAppBarTitle(strings, state.currentStep)),
        leading: AppBackButton(
          onPressed: state.isLoading
              ? null
              : () {
                  if (state.currentStep > 1) {
                    notifier.previousStep();
                  } else if (state.canPopCategoryDrill) {
                    notifier.popCategoryDrillLevel();
                  } else if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go(AppRoutes.home);
                  }
                },
        ),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              _StepIndicator(
                currentStep: state.currentStep,
                totalSteps: state.maxStep,
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => FocusScope.of(context).unfocus(),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      final offsetAnimation = Tween<Offset>(
                        begin: const Offset(-0.15, 0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ));
                      return SlideTransition(
                        position: offsetAnimation,
                        child: FadeTransition(opacity: animation, child: child),
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey(state.currentStep),
                      child: _buildStep(context, ref, state),
                    ),
                  ),
                ),
              ),
              _BottomActions(
                state: state,
                strings: strings,
                onNext: () async {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId == null) {
                    await requireAuth(context, ref);
                    return;
                  }
                  if (state.currentStep < state.maxStep) {
                    notifier.nextStep();
                  }
                },
                onPublish: () => _handlePublish(context, ref),
                onSaveDraft: () => _handleSaveDraft(context, ref),
              ),
            ],
          ),
          if (state.isLoading) _PublishOverlay(state: state, strings: strings),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, WidgetRef ref, PostListingState state) {
    if (state.isVehicleListing) {
      return switch (state.currentStep) {
        1 => const Step1Category(),
        2 => const Step2Details(),
        3 => const CarPaintConditionScreen(),
        4 => const Step3Location(),
        5 => const Step4Photos(),
        6 => const StepContactPreferences(),
        7 => const StepListingPackage(),
        8 => Step5Review(
            onPublish: () => _handlePublish(context, ref),
            onSaveDraft: () => _handleSaveDraft(context, ref),
          ),
        _ => const SizedBox.shrink(),
      };
    }

    return switch (state.currentStep) {
      1 => const Step1Category(),
      2 => const Step2Details(),
      3 => const Step3Location(),
      4 => const Step4Photos(),
      5 => const StepContactPreferences(),
      6 => const StepListingPackage(),
      7 => Step5Review(
          onPublish: () => _handlePublish(context, ref),
          onSaveDraft: () => _handleSaveDraft(context, ref),
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Future<void> _handlePublish(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }

    final state = ref.read(postListingProvider);
    final strings = ref.read(appLocalizationsProvider);
    if (state.standardRequiresPaidPublish) {
      final price = ListingPackageConfig.paidStandardPriceIqd;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text(strings.confirmListingFeeTitle),
          content: Text(
            strings.confirmListingFeeBody(formatIqdWithL10n(price, strings)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(strings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(strings.confirmAndPay(formatIqdWithL10n(price, strings))),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    final outcome =
        await ref.read(postListingProvider.notifier).publishListing();
    if (!context.mounted) return;

    if (outcome.moderationDialog != null) {
      await showModerationWarningDialog(
        context,
        variant: outcome.moderationDialog!,
        banInfo: outcome.banInfo,
        postingBanMessage: outcome.postingBanMessage,
      );
      ref.invalidateModerationState();
      if (outcome.moderationDialog == ModerationDialogVariant.blocked ||
          outcome.moderationDialog == ModerationDialogVariant.postingBan) {
        return;
      }
    }

    if (outcome.listingId != null) {
      await showListingPublishSuccessDialog(context);
      if (!context.mounted) return;
      ref.read(postListingProvider.notifier).reset();
      context.go('/listing/${outcome.listingId}');
    }
  }

  Future<void> _handleSaveDraft(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }

    final id = await ref.read(postListingProvider.notifier).saveDraft();
    if (!context.mounted) return;

    if (id != null) {
      ref.read(postListingProvider.notifier).reset();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appLocalizationsProvider).draftSaved)),
      );
      context.go(AppRoutes.myListings);
    }
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final progress = (currentStep / totalSteps).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                '$currentStep / $totalSteps',
                textDirection: TextDirection.ltr,
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pureWhite,
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.volt,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 6,
              color: AppColors.surfaceMuted,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                alignment: AlignmentDirectional.centerStart,
                widthFactor: progress,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppColors.premiumGradient,
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

class _PublishOverlay extends StatelessWidget {
  const _PublishOverlay({required this.state, required this.strings});

  final PostListingState state;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  state.statusMessage ??
                      (state.uploadTotal > 0
                          ? strings.uploadingPhotos(
                              state.uploadIndex.toString(),
                              state.uploadTotal.toString(),
                            )
                          : strings.publishingListing),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.state,
    required this.strings,
    required this.onNext,
    required this.onPublish,
    required this.onSaveDraft,
  });

  final PostListingState state;
  final AppLocalizations strings;
  final VoidCallback onNext;
  final VoidCallback onPublish;
  final VoidCallback onSaveDraft;

  @override
  Widget build(BuildContext context) {
    if (state.currentStep == state.packageStep) {
      return const SizedBox.shrink();
    }

    final isPhotosStep = state.currentStep == state.photosStep;
    final isDetailsStep = state.currentStep == 2;
    final titleValid = state.title.trim().length >= 5;
    final canProceed = (!isPhotosStep || state.images.isNotEmpty) &&
        (!isDetailsStep || titleValid);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (state.currentStep < state.maxStep)
              SizedBox(
                width: double.infinity,
                height: 54,
                child: FilledButton(
                  onPressed: state.isLoading
                      ? null
                      : () {
                          if (!canProceed) {
                            final message = isDetailsStep
                                ? strings.titleMinLengthError
                                : strings.addPhotoRequired;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  message,
                                  style: AppTextStyles.subheading.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            );
                            return;
                          }
                          onNext();
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: canProceed && !state.isLoading
                        ? AppColors.primary
                        : AppColors.surfaceMuted,
                    foregroundColor: AppColors.canvas,
                    disabledBackgroundColor: AppColors.surfaceMuted,
                    disabledForegroundColor: AppColors.textMuted,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.canvas,
                          ),
                        )
                      : Text(
                          strings.nextStep,
                          style: AppTextStyles.button,
                        ),
                ),
              )
            else ...[
              CustomButton(
                label: strings.postListing,
                loading: state.isLoading,
                onPressed: state.isLoading ? null : onPublish,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: state.isLoading ? null : onSaveDraft,
                child: Text(strings.saveAsDraft),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
