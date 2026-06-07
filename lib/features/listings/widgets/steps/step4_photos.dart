import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../providers/post_listing_provider.dart';
import '../image_picker_grid.dart';

class Step4Photos extends ConsumerWidget {
  const Step4Photos({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الصور',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'أضف حتى ${AppConstants.maxListingPhotos} صور — اسحب لإعادة الترتيب',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          ImagePickerGrid(
            images: state.images,
            maxImages: AppConstants.maxListingPhotos,
            onAdd: (file) => notifier.addImage(file),
            onRemove: notifier.removeImage,
            onReorder: notifier.reorderImages,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
