import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/image_compression.dart';
import '../../../shared/models/category_model.dart';
import '../../../shared/models/listing_model.dart';
import '../../home/providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../data/categories_repository.dart';
import 'listings_provider.dart';

class PostListingState {
  const PostListingState({
    this.currentStep = 1,
    this.selectedCategory,
    this.selectedSubcategory,
    this.expandedParentId,
    this.title = '',
    this.description = '',
    this.price,
    this.isNegotiable = false,
    this.listingType = ListingType.sale,
    this.condition,
    this.governorate,
    this.city = '',
    this.latitude,
    this.longitude,
    this.images = const [],
    this.uploadedImagePaths = const [],
    this.uploadIndex = 0,
    this.uploadTotal = 0,
    this.statusMessage,
    this.isLoading = false,
    this.error,
    this.isPublished = false,
    this.publishedListingId,
  });

  final int currentStep;
  final CategoryModel? selectedCategory;
  final CategoryModel? selectedSubcategory;
  final int? expandedParentId;
  final String title;
  final String description;
  final double? price;
  final bool isNegotiable;
  final ListingType listingType;
  final ListingCondition? condition;
  final String? governorate;
  final String city;
  final double? latitude;
  final double? longitude;
  final List<File> images;
  final List<String> uploadedImagePaths;

  /// Public URLs after upload (same order as [uploadedImagePaths]).
  List<String> get uploadedImageUrls => uploadedImagePaths;
  final int uploadIndex;
  final int uploadTotal;
  final String? statusMessage;
  final bool isLoading;
  final String? error;
  final bool isPublished;
  final String? publishedListingId;

  CategoryModel? get effectiveCategory =>
      selectedSubcategory ?? selectedCategory;

  PostListingState copyWith({
    int? currentStep,
    CategoryModel? selectedCategory,
    CategoryModel? selectedSubcategory,
    int? expandedParentId,
    bool clearExpandedParent = false,
    String? title,
    String? description,
    double? price,
    bool? isNegotiable,
    ListingType? listingType,
    ListingCondition? condition,
    String? governorate,
    String? city,
    double? latitude,
    double? longitude,
    bool clearLocation = false,
    List<File>? images,
    List<String>? uploadedImagePaths,
    int? uploadIndex,
    int? uploadTotal,
    String? statusMessage,
    bool? isLoading,
    String? error,
    bool? isPublished,
    String? publishedListingId,
    bool clearError = false,
    bool clearCategory = false,
    bool clearSubcategory = false,
  }) {
    return PostListingState(
      currentStep: currentStep ?? this.currentStep,
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSubcategory: clearSubcategory
          ? null
          : (selectedSubcategory ?? this.selectedSubcategory),
      expandedParentId: clearExpandedParent
          ? null
          : (expandedParentId ?? this.expandedParentId),
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      isNegotiable: isNegotiable ?? this.isNegotiable,
      listingType: listingType ?? this.listingType,
      condition: condition ?? this.condition,
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      images: images ?? this.images,
      uploadedImagePaths: uploadedImagePaths ?? this.uploadedImagePaths,
      uploadIndex: uploadIndex ?? this.uploadIndex,
      uploadTotal: uploadTotal ?? this.uploadTotal,
      statusMessage: statusMessage ?? this.statusMessage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPublished: isPublished ?? this.isPublished,
      publishedListingId: publishedListingId ?? this.publishedListingId,
    );
  }
}

class PostListingNotifier extends Notifier<PostListingState> {
  @override
  PostListingState build() => const PostListingState();

  void goToStep(int step) {
    state = state.copyWith(currentStep: step.clamp(1, 5), clearError: true);
  }

  void setValidationError(String message) {
    state = state.copyWith(error: message);
  }

  void nextStep() {
    final error = validateStep(state.currentStep);
    if (error != null) {
      state = state.copyWith(error: error);
      return;
    }
    if (state.currentStep < 5) {
      state = state.copyWith(
        currentStep: state.currentStep + 1,
        clearError: true,
      );
    }
  }

  void previousStep() {
    if (state.currentStep > 1) {
      state = state.copyWith(
        currentStep: state.currentStep - 1,
        clearError: true,
      );
    }
  }

  void updateField(String field, dynamic value) {
    state = switch (field) {
      'title' => state.copyWith(title: value as String, clearError: true),
      'description' =>
        state.copyWith(description: value as String, clearError: true),
      'price' => state.copyWith(price: value as double?, clearError: true),
      'isNegotiable' =>
        state.copyWith(isNegotiable: value as bool, clearError: true),
      'listingType' =>
        state.copyWith(listingType: value as ListingType, clearError: true),
      'condition' =>
        state.copyWith(condition: value as ListingCondition?, clearError: true),
      'governorate' =>
        state.copyWith(governorate: value as String?, clearError: true),
      'city' => state.copyWith(city: value as String, clearError: true),
      'latitude' => state.copyWith(latitude: value as double?, clearError: true),
      'longitude' =>
        state.copyWith(longitude: value as double?, clearError: true),
      _ => state,
    };
  }

  void selectParentCategory(CategoryModel category, List<CategoryModel> all) {
    final subs = all.where((c) => c.parentId == category.id).toList();
    final sameParent = state.selectedCategory?.id == category.id;
    state = state.copyWith(
      expandedParentId: category.id,
      selectedCategory: category,
      clearSubcategory: subs.isEmpty || !sameParent,
      selectedSubcategory:
          subs.isEmpty || !sameParent ? null : state.selectedSubcategory,
      clearError: true,
    );
  }

  void selectSubcategory(CategoryModel sub) {
    state = state.copyWith(selectedSubcategory: sub, clearError: true);
  }

  Future<void> addImage(File file) async {
    if (state.images.length >= AppConstants.maxListingPhotos) {
      state = state.copyWith(
        error: 'الحد الأقصى ${AppConstants.maxListingPhotos} صور',
      );
      return;
    }
    try {
      final compressed = await compressListingImage(file);
      state = state.copyWith(
        images: [...state.images, compressed],
        clearError: true,
      );
    } catch (_) {
      state = state.copyWith(error: 'تعذّر معالجة الصورة');
    }
  }

  void removeImage(int index) {
    final images = [...state.images]..removeAt(index);
    state = state.copyWith(images: images, clearError: true);
  }

  void reorderImages(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    final images = [...state.images];
    final item = images.removeAt(oldIndex);
    images.insert(newIndex, item);
    state = state.copyWith(images: images);
  }

  void clearLocation() {
    state = state.copyWith(clearLocation: true);
  }

  String? _validateCategory() {
    if (state.selectedCategory == null) return 'اختر الفئة';
    final allAsync = ref.read(allCategoriesProvider);
    final hasSubs = allAsync.maybeWhen(
      data: (cats) =>
          cats.any((c) => c.parentId == state.selectedCategory!.id),
      orElse: () => false,
    );
    if (hasSubs && state.selectedSubcategory == null) {
      return 'اختر الفئة الفرعية';
    }
    return null;
  }

  String? validateStep(int step) {
    return switch (step) {
      1 => _validateCategory(),
      2 => _validateDetails(),
      3 => (state.governorate == null || state.city.trim().isEmpty)
          ? 'اختر المحافظة والمدينة'
          : null,
      4 => state.images.isEmpty ? 'أضف صورة واحدة على الأقل' : null,
      5 => null,
      _ => null,
    };
  }

  String? _validateDetails() {
    if (state.title.trim().isEmpty) return 'أدخل عنوان الإعلان';
    if (state.title.trim().length > 100) {
      return 'العنوان طويل جداً (100 حرف كحد أقصى)';
    }
    if (state.description.trim().isEmpty) return 'أدخل وصف الإعلان';
    if (state.description.trim().length > 2000) {
      return 'الوصف طويل جداً (2000 حرف كحد أقصى)';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    if (state.condition == null) return 'اختر حالة المنتج';
    return null;
  }

  Future<List<String>> uploadImages(String userId) async {
    final paths = <String>[];
    final batchId = DateTime.now().millisecondsSinceEpoch;
    final repo = ref.read(listingsRepositoryProvider);

    state = state.copyWith(
      isLoading: true,
      uploadTotal: state.images.length,
      uploadIndex: 0,
      statusMessage: 'جاري رفع الصور...',
      clearError: true,
    );

    for (var i = 0; i < state.images.length; i++) {
      state = state.copyWith(
        uploadIndex: i + 1,
        statusMessage: 'جاري رفع الصور... (${i + 1}/${state.images.length})',
      );
      final path = await repo.uploadListingImage(
        userId: userId,
        image: state.images[i],
        index: i,
        batchId: batchId,
      );
      paths.add(path);
    }

    state = state.copyWith(
      uploadedImagePaths: paths,
      statusMessage: 'جاري نشر الإعلان...',
    );
    return paths;
  }

  Future<String?> publishListing() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return null;

    for (var step = 1; step <= 4; step++) {
      final stepError = validateStep(step);
      if (stepError != null) {
        state = state.copyWith(error: stepError);
        return null;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final imagePaths = state.uploadedImagePaths.isNotEmpty
          ? state.uploadedImagePaths
          : await uploadImages(userId);

      final id = await ref.read(listingsRepositoryProvider).createListingRecord(
            userId: userId,
            categoryId: state.effectiveCategory!.id,
            title: state.title.trim(),
            description: state.description.trim(),
            price: state.price!,
            isNegotiable: state.isNegotiable,
            condition: state.condition!,
            city: state.city.trim(),
            governorate: state.governorate!,
            latitude: state.latitude,
            longitude: state.longitude,
            imageStoragePaths: imagePaths,
            asDraft: false,
            listingType: state.listingType.value,
          );

      state = state.copyWith(
        isLoading: false,
        isPublished: true,
        publishedListingId: id,
        statusMessage: null,
      );

      invalidateMyListingsProviders(ref);
      ref.invalidate(recentListingsProvider);
      ref.invalidate(featuredListingsProvider);
      return id;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'تعذّر نشر الإعلان. حاول مرة أخرى.',
        statusMessage: null,
      );
      return null;
    }
  }

  Future<String?> saveDraft() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return null;

    if (state.effectiveCategory == null) {
      state = state.copyWith(error: 'اختر الفئة على الأقل');
      return null;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      var imagePaths = state.uploadedImagePaths;
      if (imagePaths.isEmpty && state.images.isNotEmpty) {
        imagePaths = await uploadImages(userId);
      }

      final id = await ref.read(listingsRepositoryProvider).createListingRecord(
            userId: userId,
            categoryId: state.effectiveCategory!.id,
            title: state.title.trim().isEmpty ? 'مسودة' : state.title.trim(),
            description: state.description.trim(),
            price: state.price ?? 0,
            isNegotiable: state.isNegotiable,
            condition: state.condition,
            city: state.city.trim().isEmpty ? '—' : state.city.trim(),
            governorate: state.governorate ?? 'baghdad',
            latitude: state.latitude,
            longitude: state.longitude,
            imageStoragePaths: imagePaths,
            asDraft: true,
            listingType: state.listingType.value,
          );

      state = state.copyWith(
        isLoading: false,
        isPublished: true,
        publishedListingId: id,
        statusMessage: null,
      );
      invalidateMyListingsProviders(ref);
      return id;
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        error: 'تعذّر حفظ المسودة',
        statusMessage: null,
      );
      return null;
    }
  }

  void reset() {
    state = const PostListingState();
  }

  void applyLoadedState(PostListingState loaded) {
    state = loaded;
  }
}

final postListingProvider =
    NotifierProvider<PostListingNotifier, PostListingState>(
  PostListingNotifier.new,
);

final allCategoriesProvider = FutureProvider<List<CategoryModel>>((ref) async {
  return ref.watch(categoriesRepositoryProvider).fetchAll();
});

/// Direct children for category browse drill-down (queries DB by parent_id).
final categoryBrowseChildrenProvider =
    FutureProvider.autoDispose.family<List<CategoryModel>, int>((ref, parentId) async {
  return ref.read(categoriesRepositoryProvider).fetchChildren(parentId);
});

final categoryListingCountsProvider =
    FutureProvider.family<Map<int, int>, String?>((ref, listingType) async {
  return ref
      .watch(categoriesRepositoryProvider)
      .fetchListingCountsByCategory(listingType: listingType);
});

final imagePickerServiceProvider = Provider((ref) => ImagePicker());
