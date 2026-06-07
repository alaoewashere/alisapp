import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/listings_repository.dart';
import 'listing_detail_provider.dart';
import 'listings_provider.dart';
import 'post_listing_provider.dart';

class EditListingState {
  const EditListingState({
    this.loaded = false,
    this.loading = false,
    this.error,
    this.listingId,
    this.existingImages = const [],
    this.removedImageIds = const [],
  });

  final bool loaded;
  final bool loading;
  final String? error;
  final String? listingId;
  final List<ListingImage> existingImages;
  final List<String> removedImageIds;

  EditListingState copyWith({
    bool? loaded,
    bool? loading,
    String? error,
    String? listingId,
    List<ListingImage>? existingImages,
    List<String>? removedImageIds,
    bool clearError = false,
  }) {
    return EditListingState(
      loaded: loaded ?? this.loaded,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      listingId: listingId ?? this.listingId,
      existingImages: existingImages ?? this.existingImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
    );
  }
}

class EditListingNotifier extends Notifier<EditListingState> {
  EditListingNotifier(this.listingId);

  final String listingId;

  @override
  EditListingState build() {
    Future.microtask(load);
    return EditListingState(listingId: listingId, loading: true);
  }

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final listing =
          await ref.read(listingsRepositoryProvider).getListingById(listingId);
      if (listing == null) {
        state = state.copyWith(loading: false, error: 'الإعلان غير موجود');
        return;
      }

      final all = await ref.read(allCategoriesProvider.future);
      CategoryModel? parent;
      CategoryModel? sub;
      for (final c in all) {
        if (c.id == listing.categoryId) {
          if (c.isParent) {
            parent = c;
          } else {
            sub = c;
            for (final p in all) {
              if (p.id == c.parentId) parent = p;
            }
          }
          break;
        }
      }

      ref.read(postListingProvider.notifier).applyLoadedState(
            PostListingState(
              title: listing.titleAr,
              description: listing.descriptionAr,
              price: listing.price,
              isNegotiable: listing.isNegotiable,
              condition: listing.condition,
              governorate: listing.governorate,
              city: listing.city,
              latitude: listing.latitude,
              longitude: listing.longitude,
              selectedCategory: parent,
              selectedSubcategory: sub,
              expandedParentId: parent?.id,
            ),
          );

      state = EditListingState(
        loaded: true,
        listingId: listingId,
        existingImages: listing.images,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'تعذّر تحميل الإعلان',
      );
    }
  }

  void removeExistingImage(String imageId) {
    state = state.copyWith(
      existingImages:
          state.existingImages.where((i) => i.id != imageId).toList(),
      removedImageIds: [...state.removedImageIds, imageId],
    );
  }

  Future<bool> save() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return false;

    final post = ref.read(postListingProvider);
    state = state.copyWith(loading: true, clearError: true);

    try {
      final newPaths = <String>[];
      if (post.images.isNotEmpty) {
        final batchId = DateTime.now().millisecondsSinceEpoch;
        for (var i = 0; i < post.images.length; i++) {
          final path = await ref.read(listingsRepositoryProvider).uploadListingImage(
                userId: userId,
                image: post.images[i],
                index: i,
                batchId: batchId,
              );
          newPaths.add(path);
        }
      }

      final imageRows = <Map<String, dynamic>>[];
      var order = 0;
      for (final img in state.existingImages) {
        imageRows.add({
          'id': img.id,
          'listing_id': listingId,
          'storage_path': _storagePathFromUrl(img),
          'sort_order': order,
          'is_primary': order == 0,
        });
        order++;
      }
      for (final path in newPaths) {
        imageRows.add({
          'listing_id': listingId,
          'storage_path': path,
          'sort_order': order,
          'is_primary': imageRows.isEmpty && order == 0,
        });
        order++;
      }

      await ref.read(listingsRepositoryProvider).updateListing(
            listingId: listingId,
            categoryId: post.effectiveCategory!.id,
            title: post.title.trim(),
            description: post.description.trim(),
            price: post.price ?? 0,
            isNegotiable: post.isNegotiable,
            condition: post.condition,
            city: post.city.trim(),
            governorate: post.governorate ?? '',
            latitude: post.latitude,
            longitude: post.longitude,
            imageRows: imageRows,
            removedImageIds: state.removedImageIds,
          );

      ref.invalidate(listingDetailProvider(listingId));
      ref.invalidate(recentListingsProvider);
      invalidateMyListingsProviders(ref);
      ref.read(postListingProvider.notifier).reset();
      state = state.copyWith(loading: false);
      return true;
    } catch (_) {
      state = state.copyWith(loading: false, error: 'تعذّر حفظ التعديلات');
      return false;
    }
  }

  String _storagePathFromUrl(ListingImage img) {
    final url = img.url ?? img.storagePath;
    if (!url.startsWith('http')) return url;
    final parts = Uri.parse(url).pathSegments;
    final idx = parts.indexOf(AppConstants.storageBucket);
    if (idx >= 0 && idx + 1 < parts.length) {
      return parts.sublist(idx + 1).join('/');
    }
    return img.storagePath;
  }
}

final editListingProvider =
    NotifierProvider.family<EditListingNotifier, EditListingState, String>(
  EditListingNotifier.new,
);
