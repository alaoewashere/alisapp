import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/widgets/custom_button.dart';
import '../providers/post_listing_provider.dart';
import '../widgets/steps/step1_category.dart';
import '../widgets/steps/step2_details.dart';
import '../widgets/steps/step3_location.dart';
import '../widgets/steps/step4_photos.dart';
import '../widgets/steps/step5_review.dart';

class PostListingScreen extends ConsumerWidget {
  const PostListingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('نشر إعلان'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: state.isLoading
              ? null
              : () {
                  if (state.currentStep > 1) {
                    notifier.previousStep();
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
              _StepIndicator(currentStep: state.currentStep),
              Expanded(
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
                    child: _buildStep(context, ref, state.currentStep),
                  ),
                ),
              ),
              _BottomActions(
                currentStep: state.currentStep,
                isLoading: state.isLoading,
                onNext: () async {
                  final userId = ref.read(currentUserIdProvider);
                  if (userId == null) {
                    await requireAuth(context, ref);
                    return;
                  }
                  if (state.currentStep < 5) {
                    notifier.nextStep();
                  }
                },
                onPublish: () => _handlePublish(context, ref),
                onSaveDraft: () => _handleSaveDraft(context, ref),
              ),
            ],
          ),
          if (state.isLoading) _PublishOverlay(state: state),
        ],
      ),
    );
  }

  Widget _buildStep(BuildContext context, WidgetRef ref, int step) {
    return switch (step) {
      1 => const Step1Category(),
      2 => const Step2Details(),
      3 => const Step3Location(),
      4 => const Step4Photos(),
      5 => Step5Review(
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

    final id = await ref.read(postListingProvider.notifier).publishListing();
    if (!context.mounted) return;

    if (id != null) {
      ref.read(postListingProvider.notifier).reset();
      context.go('/listing/$id');
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
        const SnackBar(content: Text('تم حفظ المسودة')),
      );
      context.go(AppRoutes.myListings);
    }
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

class _PublishOverlay extends StatelessWidget {
  const _PublishOverlay({required this.state});

  final PostListingState state;

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
                          ? 'جاري رفع الصور... (${state.uploadIndex}/${state.uploadTotal})'
                          : 'جاري نشر الإعلان...'),
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
    required this.currentStep,
    required this.isLoading,
    required this.onNext,
    required this.onPublish,
    required this.onSaveDraft,
  });

  final int currentStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback onPublish;
  final VoidCallback onSaveDraft;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (currentStep < 5)
              CustomButton(
                label: 'التالي',
                loading: isLoading,
                onPressed: isLoading ? null : onNext,
              )
            else ...[
              CustomButton(
                label: 'نشر الإعلان',
                loading: isLoading,
                onPressed: isLoading ? null : onPublish,
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: isLoading ? null : onSaveDraft,
                child: const Text('حفظ كمسودة'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
