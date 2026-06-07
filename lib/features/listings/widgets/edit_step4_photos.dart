import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../providers/edit_listing_provider.dart';
import '../providers/post_listing_provider.dart';
import 'image_picker_grid.dart';

/// Step 4 for edit: existing URL images + new local photos.
class EditStep4Photos extends ConsumerWidget {
  const EditStep4Photos({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final edit = ref.watch(editListingProvider(listingId));
    final post = ref.watch(postListingProvider);
    final notifier = ref.read(editListingProvider(listingId).notifier);
    final postNotifier = ref.read(postListingProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'الصور',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (edit.existingImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text('الصور الحالية', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: edit.existingImages.map((img) {
                final url = img.url ?? img.storagePath;
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CachedNetworkImage(
                        imageUrl: url,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        icon: const Icon(Icons.close, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => notifier.removeExistingImage(img.id),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            'أضف صوراً جديدة (اختياري)',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          ImagePickerGrid(
            images: post.images,
            maxImages: AppConstants.maxListingPhotos -
                edit.existingImages.length,
            onAdd: postNotifier.addImage,
            onRemove: postNotifier.removeImage,
            onReorder: postNotifier.reorderImages,
          ),
          if (post.error != null) ...[
            const SizedBox(height: 12),
            Text(
              post.error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }
}
