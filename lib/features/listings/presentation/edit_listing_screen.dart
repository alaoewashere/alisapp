import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../providers/edit_listing_provider.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/edit_step4_photos.dart';
import '../widgets/steps/step1_category.dart';
import '../widgets/steps/step2_details.dart';
import '../widgets/steps/step3_location.dart';
import '../widgets/steps/step5_review.dart';

class EditListingScreen extends ConsumerWidget {
  const EditListingScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(editListingProvider(listingId));
    final post = ref.watch(postListingProvider);

    if (edit.loading && !edit.loaded) {
      return const Scaffold(body: LoadingWidget(message: 'جاري التحميل...'));
    }
    if (edit.error != null && !edit.loaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('تعديل الإعلان')),
        body: AppErrorWidget(
          message: edit.error!,
          onRetry: () => ref.invalidate(editListingProvider(listingId)),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الإعلان'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (post.currentStep > 1) {
              ref.read(postListingProvider.notifier).previousStep();
            } else {
              ref.read(postListingProvider.notifier).reset();
              context.pop();
            }
          },
        ),
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: post.currentStep),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: KeyedSubtree(
                key: ValueKey(post.currentStep),
                child: switch (post.currentStep) {
                  1 => const Step1Category(),
                  2 => const Step2Details(),
                  3 => const Step3Location(),
                  4 => EditStep4Photos(listingId: listingId),
                  5 => Step5Review(
                      onPublish: () => _save(context, ref),
                      onSaveDraft: () {},
                    ),
                  _ => const SizedBox.shrink(),
                },
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: post.currentStep < 5
                  ? CustomButton(
                      label: 'التالي',
                      loading: edit.loading,
                      onPressed: edit.loading
                          ? null
                          : () => _nextStep(ref, post.currentStep),
                    )
                  : CustomButton(
                      label: 'حفظ التعديلات',
                      loading: edit.loading,
                      onPressed: edit.loading ? null : () => _save(context, ref),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _save(BuildContext context, WidgetRef ref) async {
    final ok = await ref.read(editListingProvider(listingId).notifier).save();
    if (!context.mounted) return;
    if (ok) {
      context.pop();
      context.push('/listing/$listingId');
    }
  }

  void _nextStep(WidgetRef ref, int step) {
    final postNotifier = ref.read(postListingProvider.notifier);
    if (step == 4) {
      final edit = ref.read(editListingProvider(listingId));
      final post = ref.read(postListingProvider);
      if (edit.existingImages.isEmpty && post.images.isEmpty) {
        postNotifier.setValidationError('أضف صورة واحدة على الأقل');
        return;
      }
      if (edit.existingImages.isNotEmpty && post.images.isEmpty) {
        postNotifier.goToStep(5);
        return;
      }
    }
    postNotifier.nextStep();
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (i) {
          final step = i + 1;
          final active = step == currentStep;
          final done = step < currentStep;
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: active ? 12 : 8,
            height: active ? 12 : 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active || done
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          );
        }),
      ),
    );
  }
}
