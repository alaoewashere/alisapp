import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/moderation/moderation_provider.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/animal_listing_utils.dart';
import '../../../core/utils/category_tree.dart';
import '../../../core/utils/electronics_listing_utils.dart';
import '../../../core/utils/general_listing_utils.dart';
import '../../../core/utils/home_service_listing_utils.dart';
import '../../../core/utils/job_listing_utils.dart';
import '../../../core/utils/real_estate_listing_utils.dart';
import '../../../core/utils/tutoring_listing_utils.dart';
import '../../../core/utils/vehicle_listing_utils.dart';
import '../../../services/video_service.dart';
import '../../../shared/models/animal_listing_metadata.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/electronics_listing_metadata.dart';
import '../../../shared/models/general_listing_metadata.dart';
import '../../../shared/models/home_service_listing_metadata.dart';
import '../../../shared/models/job_listing_metadata.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/real_estate_listing_metadata.dart';
import '../../../shared/models/tutoring_listing_metadata.dart';
import '../../../shared/models/vehicle_listing_metadata.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/listings_repository.dart';
import '../models/edit_listing_snapshot.dart';
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
    this.loadedPrice,
    this.snapshot,
    this.existingVideoUrl,
    this.existingVideoThumbnailUrl,
    this.canUploadVideo = false,
  });

  final bool loaded;
  final bool loading;
  final String? error;
  final String? listingId;
  final List<ListingImage> existingImages;
  final List<String> removedImageIds;
  final double? loadedPrice;
  final EditListingSnapshot? snapshot;
  final String? existingVideoUrl;
  final String? existingVideoThumbnailUrl;
  final bool canUploadVideo;

  EditListingState copyWith({
    bool? loaded,
    bool? loading,
    String? error,
    String? listingId,
    List<ListingImage>? existingImages,
    List<String>? removedImageIds,
    double? loadedPrice,
    EditListingSnapshot? snapshot,
    String? existingVideoUrl,
    String? existingVideoThumbnailUrl,
    bool? canUploadVideo,
    bool clearError = false,
  }) {
    return EditListingState(
      loaded: loaded ?? this.loaded,
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
      listingId: listingId ?? this.listingId,
      existingImages: existingImages ?? this.existingImages,
      removedImageIds: removedImageIds ?? this.removedImageIds,
      loadedPrice: loadedPrice ?? this.loadedPrice,
      snapshot: snapshot ?? this.snapshot,
      existingVideoUrl: existingVideoUrl ?? this.existingVideoUrl,
      existingVideoThumbnailUrl:
          existingVideoThumbnailUrl ?? this.existingVideoThumbnailUrl,
      canUploadVideo: canUploadVideo ?? this.canUploadVideo,
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
        state = state.copyWith(
          loading: false,
          error: ref.read(appLocalizationsProvider).listingNotFound,
        );
        return;
      }

      final currentUserId = ref.read(currentUserIdProvider);
      if (currentUserId == null || listing.userId != currentUserId) {
        state = state.copyWith(
          loading: false,
          error: ref.read(appLocalizationsProvider).cannotEditListingError,
        );
        return;
      }

      final all = await ref.read(allCategoriesProvider.future);
      CategoryModel? leaf;
      for (final c in all) {
        if (c.id == listing.categoryId) {
          leaf = c;
          break;
        }
      }
      final categoryPath =
          leaf != null ? buildCategoryPath(leaf.id, all) : <CategoryModel>[];

      final package = _listingPackage(listing);

      ref.read(postListingProvider.notifier).applyLoadedState(
            PostListingState(
              currentStep: 1,
              title: listing.titleAr,
              description: listing.descriptionAr,
              price: listing.price,
              isNegotiable: listing.isNegotiable,
              condition: listing.condition,
              governorate: listing.governorate,
              city: listing.city,
              latitude: listing.latitude,
              longitude: listing.longitude,
              locationAddress: listing.locationAddress,
              areaName: listing.areaName,
              areaNameLocked: listing.areaName?.trim().isNotEmpty == true,
              categoryPath: categoryPath,
              selectedCategory:
                  categoryPath.isNotEmpty ? categoryPath.last : null,
              contactPreference: listing.contactPreference,
              listingPackage: package,
              vehicleDetails:
                  listing.vehicleMetadata ?? const VehicleListingMetadata(),
              realEstateDetails: listing.realEstateMetadata ??
                  const RealEstateListingMetadata(),
              electronicsDetails: listing.electronicsMetadata ??
                  (hasElectronicsSubForm(categoryPath)
                      ? deriveElectronicsDetailsFromPath(
                          categoryPath,
                          electronicsFormKind(categoryPath),
                        )
                      : const ElectronicsListingMetadata()),
              generalDetails: listing.generalMetadata ??
                  (isGeneralMarketplaceCategoryPath(categoryPath)
                      ? initialGeneralDetailsForPath(categoryPath)
                      : const GeneralListingMetadata()),
              tutoringDetails: listing.tutoringMetadata ??
                  (isTutoringCategoryPath(categoryPath)
                      ? deriveTutoringDetailsFromPath(categoryPath)
                      : const TutoringListingMetadata()),
              jobDetails: listing.jobMetadata ??
                  (isJobCategoryPath(categoryPath)
                      ? deriveJobDetailsFromPath(categoryPath)
                      : const JobListingMetadata()),
              animalDetails: listing.animalMetadata ??
                  (isAnimalCategoryPath(categoryPath)
                      ? deriveAnimalDetailsFromPath(categoryPath)
                      : const AnimalListingMetadata()),
              homeServiceDetails: listing.homeServiceMetadata ??
                  (isHomeServiceCategoryPath(categoryPath)
                      ? deriveHomeServiceDetailsFromPath(categoryPath)
                      : const HomeServiceListingMetadata()),
            ),
          );

      state = EditListingState(
        loaded: true,
        loading: false,
        listingId: listingId,
        existingImages: listing.images,
        loadedPrice: listing.price,
        snapshot: EditListingSnapshot.fromListing(listing),
        existingVideoUrl: listing.videoUrl,
        existingVideoThumbnailUrl: listing.videoThumbnailUrl,
        canUploadVideo: package.allowsListingVideo,
      );
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: ref.read(appLocalizationsProvider).loadListingFailedError,
      );
    }
  }

  ListingPackage _listingPackage(ListingModel listing) {
    final metaPackage = listing.metadata['listing_package'] as String?;
    if (metaPackage != null) {
      return ListingPackage.fromString(metaPackage);
    }
    if (listing.isPremiumListing) return ListingPackage.premium;
    if (listing.isProListing) return ListingPackage.pro;
    return ListingPackage.standard;
  }

  void removeExistingImage(String imageId) {
    state = state.copyWith(
      existingImages:
          state.existingImages.where((i) => i.id != imageId).toList(),
      removedImageIds: [...state.removedImageIds, imageId],
    );
  }

  Future<EditListingSaveOutcome> save() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return const EditListingSaveOutcome(success: false);

    final profile = ref.read(currentProfileProvider).value;
    if (profile != null && isUserPostingBanned(profile)) {
      return EditListingSaveOutcome(
        success: false,
        moderationDialog: ModerationDialogVariant.postingBan,
        postingBanMessage: postingBanMessage(
          ref.read(appLocalizationsProvider),
          profile,
        ),
      );
    }

    final snapshot = state.snapshot;
    if (snapshot == null) return const EditListingSaveOutcome(success: false);

    final postNotifier = ref.read(postListingProvider.notifier);
    final postState = ref.read(postListingProvider);
    _syncCategoryMetadata(postNotifier, postState);
    final post = ref.read(postListingProvider);

    if (post.title.trim().isEmpty) {
      postNotifier.setValidationError(
        ref.read(appLocalizationsProvider).enterListingTitleError,
      );
      return const EditListingSaveOutcome(success: false);
    }

    if (state.existingImages.isEmpty && post.images.isEmpty) {
      postNotifier.setValidationError(
        ref.read(appLocalizationsProvider).addAtLeastOnePhotoError,
      );
      return const EditListingSaveOutcome(success: false);
    }

    state = state.copyWith(loading: true, clearError: true);

    try {
      final city = normalizeEditListingCity(
        governorate: post.governorate ?? '',
        city: post.city,
      );

      final categoryMetadata = _categoryMetadataForSave(post);
      final metadata = mergeEditListingMetadata(
        original: snapshot.metadata,
        categoryMetadata: categoryMetadata,
      );

      final moderation = await moderateFieldsForUser(
        ref,
        fields: {
          'title': post.title.trim(),
          'description': post.description.trim(),
        },
      );
      if (moderation.shouldBlock) {
        PostingBanInfo? banInfo;
        try {
          banInfo = await recordClientModerationBlock(
            ref.read(moderationRepositoryProvider),
            source: 'listing',
            fieldName: 'title/description',
            excerpt: post.title.trim(),
          );
        } catch (_) {
          banInfo = null;
        }
        ref.invalidateModerationState();
        state = state.copyWith(loading: false);
        return EditListingSaveOutcome(
          success: false,
          moderationDialog: ModerationDialogVariant.blocked,
          banInfo: banInfo,
        );
      }

      final moderatedTitle = post.title.trim();
      final moderatedDescription = post.description.trim();

      final fieldUpdates = buildEditListingFieldUpdates(
        original: snapshot,
        title: moderatedTitle,
        description: moderatedDescription,
        price: post.price ?? 0,
        isNegotiable: post.isNegotiable,
        condition: post.condition,
        governorate: post.governorate ?? '',
        city: city,
        latitude: post.latitude,
        longitude: post.longitude,
        locationAddress: post.locationAddress,
        areaName: post.areaName,
        contactPreference: post.contactPreference,
        metadata: metadata,
      );

      debugPrint('Edit listing fieldUpdates: $fieldUpdates');

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

      final imagesDirty = imagesChanged(
        original: snapshot,
        currentImageIds: state.existingImages.map((i) => i.id).toList(),
        removedImageIds: state.removedImageIds,
        newImageCount: post.images.length,
      );

      if (fieldUpdates.isEmpty && !imagesDirty && post.pendingVideoFile == null) {
        state = state.copyWith(loading: false);
        return EditListingSaveOutcome(
          success: true,
          moderationDialog: moderation.hadViolation
              ? ModerationDialogVariant.censored
              : null,
        );
      }

      if (fieldUpdates.isNotEmpty || imagesDirty) {
        await ref.read(listingsRepositoryProvider).patchListing(
              listingId: listingId,
              userId: userId,
              fields: fieldUpdates,
              imageRows: imageRows,
              removedImageIds: state.removedImageIds,
              imagesDirty: imagesDirty,
            );
      }

      if (post.pendingVideoFile != null &&
          post.listingPackage.allowsListingVideo) {
        final upload = await ref.read(videoServiceProvider).uploadVideo(
              videoFile: post.pendingVideoFile!,
              listingId: listingId,
              onProgress: (_) {},
            );
        await ref.read(listingsRepositoryProvider).updateListingVideo(
              listingId: listingId,
              videoUrl: upload.videoUrl,
              thumbnailUrl: upload.thumbnailUrl,
              durationSeconds: upload.durationSeconds,
            );
      }

      ref.invalidate(listingDetailProvider(listingId));
      ref.invalidate(recentListingsProvider);
      ref.invalidate(latestHomeListingsProvider);
      invalidateMyListingsProviders(ref);
      ref.read(postListingProvider.notifier).reset();
      state = state.copyWith(loading: false);
      return EditListingSaveOutcome(
        success: true,
        moderationDialog: moderation.hadViolation
            ? ModerationDialogVariant.censored
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Edit listing error: $e');
      debugPrint('Stack trace: $stackTrace');
      if (isUserPostingBannedError(e)) {
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(loading: false, clearError: true);
        return EditListingSaveOutcome(
          success: false,
          moderationDialog: ModerationDialogVariant.postingBan,
          postingBanMessage: extractPostingBanMessage(e),
        );
      }
      if (isModerationBlockedError(e)) {
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(loading: false, clearError: true);
        return const EditListingSaveOutcome(
          success: false,
          moderationDialog: ModerationDialogVariant.blocked,
        );
      }
      state = state.copyWith(
        loading: false,
        error: ref.read(appLocalizationsProvider).saveEditsFailedError,
      );
      return const EditListingSaveOutcome(success: false);
    }
  }

  void _syncCategoryMetadata(
    PostListingNotifier postNotifier,
    PostListingState postState,
  ) {
    if (postState.isVehicleListing) {
      postNotifier.syncVehicleListingCopy();
    } else if (postState.isRealEstateListing) {
      postNotifier.syncRealEstateListingCopy();
    } else if (postState.isElectronicsListing) {
      postNotifier.syncElectronicsListingCopy();
    } else if (postState.isGeneralMarketplaceListing) {
      postNotifier.syncGeneralListingCopy();
    } else if (postState.isTutoringListing) {
      postNotifier.syncTutoringListingCopy();
    } else if (postState.isJobListing) {
      postNotifier.syncJobListingCopy();
    } else if (postState.isAnimalListing) {
      postNotifier.syncAnimalListingCopy();
    } else if (postState.isHomeServiceListing) {
      postNotifier.syncHomeServiceListingCopy();
    }
  }

  Map<String, dynamic>? _categoryMetadataForSave(PostListingState post) {
    if (post.isVehicleListing) {
      return vehicleMetadataForStorage(post.vehicleDetails);
    }
    if (post.isRealEstateListing) {
      return realEstateMetadataForStorage(post.realEstateDetails);
    }
    if (post.isElectronicsListing) {
      return electronicsMetadataForStorage(post.electronicsDetails);
    }
    if (post.isGeneralMarketplaceListing) {
      return generalMetadataForStorage(post.generalDetails);
    }
    if (post.isTutoringListing) {
      return tutoringMetadataForStorage(post.tutoringDetails);
    }
    if (post.isJobListing) {
      return jobMetadataForStorage(post.jobDetails);
    }
    if (post.isAnimalListing) {
      return animalMetadataForStorage(post.animalDetails);
    }
    if (post.isHomeServiceListing) {
      return homeServiceMetadataForStorage(post.homeServiceDetails);
    }
    return null;
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
