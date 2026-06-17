import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/car_paint_panels.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/image_compression.dart';
import '../../../core/utils/animal_listing_utils.dart';
import '../../../core/utils/electronics_listing_utils.dart';
import '../../../core/utils/free_posts_quota.dart';
import '../../../core/utils/general_listing_utils.dart';
import '../../../core/utils/home_service_listing_utils.dart';
import '../../../core/utils/job_listing_utils.dart';
import '../../../core/utils/real_estate_listing_utils.dart';
import '../../../core/utils/tutoring_listing_utils.dart';
import '../../../core/utils/vehicle_listing_utils.dart';
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
import '../data/categories_repository.dart';
import '../constants/listing_package_config.dart';
import '../../../services/video_service.dart';
import 'category_details_defaults.dart';
import 'listings_provider.dart';

class PostListingState {
  const PostListingState({
    this.currentStep = 1,
    this.categoryPath = const [],
    this.categoryDrillStack = const [],
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
    this.locationAddress,
    this.images = const [],
    this.uploadedImagePaths = const [],
    this.uploadIndex = 0,
    this.uploadTotal = 0,
    this.statusMessage,
    this.isLoading = false,
    this.error,
    this.isPublished = false,
    this.publishedListingId,
    this.vehicleDetails = const VehicleListingMetadata(),
    this.realEstateDetails = const RealEstateListingMetadata(),
    this.electronicsDetails = const ElectronicsListingMetadata(),
    this.generalDetails = const GeneralListingMetadata(),
    this.tutoringDetails = const TutoringListingMetadata(),
    this.jobDetails = const JobListingMetadata(),
    this.animalDetails = const AnimalListingMetadata(),
    this.homeServiceDetails = const HomeServiceListingMetadata(),
    this.configuredPaintPanels = const {},
    this.allPartsOriginalDeclared = false,
    this.contactPreference,
    this.listingPackage = ListingPackage.standard,
    this.pendingVideoFile,
    this.pendingVideoThumbnail,
    this.videoDurationSeconds,
    this.videoProcessingProgress = 0,
    this.isVideoProcessing = false,
    this.freePostsUsedThisMonth = -1,
  });

  final int currentStep;
  final List<CategoryModel> categoryPath;

  /// Child category grids for each drill-down level (empty at root).
  final List<List<CategoryModel>> categoryDrillStack;
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
  final String? locationAddress;
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
  final VehicleListingMetadata vehicleDetails;
  final RealEstateListingMetadata realEstateDetails;
  final ElectronicsListingMetadata electronicsDetails;
  final GeneralListingMetadata generalDetails;
  final TutoringListingMetadata tutoringDetails;
  final JobListingMetadata jobDetails;
  final AnimalListingMetadata animalDetails;
  final HomeServiceListingMetadata homeServiceDetails;
  final Set<String> configuredPaintPanels;
  final bool allPartsOriginalDeclared;
  final ListingContactPreference? contactPreference;
  final ListingPackage listingPackage;
  final File? pendingVideoFile;
  final File? pendingVideoThumbnail;
  final int? videoDurationSeconds;
  final double videoProcessingProgress;
  final bool isVideoProcessing;
  final int freePostsUsedThisMonth;

  bool get freePostQuotaLoaded => freePostsUsedThisMonth >= 0;

  int get freePostsRemaining =>
      freePostQuotaLoaded ? remainingFreePosts(freePostsUsedThisMonth) : 0;

  bool get standardRequiresPaidPublish =>
      listingPackage == ListingPackage.standard &&
      freePostQuotaLoaded &&
      standardListingRequiresPayment(freePostsUsedThisMonth);

  CategoryModel? get effectiveCategory =>
      selectedCategory ?? selectedSubcategory;

  bool get isVehicleListing => isVehicleCategoryPath(categoryPath);
  bool get isRealEstateListing => isRealEstateCategoryPath(categoryPath);
  bool get isElectronicsListing => hasElectronicsSubForm(categoryPath);
  bool get isGeneralMarketplaceListing =>
      isGeneralMarketplaceCategoryPath(categoryPath);
  bool get isTutoringListing => isTutoringCategoryPath(categoryPath);
  bool get isJobListing => isJobCategoryPath(categoryPath);
  bool get isAnimalListing => isAnimalCategoryPath(categoryPath);
  bool get isHomeServiceListing => isHomeServiceCategoryPath(categoryPath);

  int get maxStep => isVehicleListing ? 8 : 7;
  int get locationStep => isVehicleListing ? 4 : 3;
  int get photosStep => isVehicleListing ? 5 : 4;
  int get contactStep => isVehicleListing ? 6 : 5;
  int get packageStep => isVehicleListing ? 7 : 6;
  int get reviewStep => maxStep;
  int get lastStepBeforeReview => maxStep - 1;

  Map<String, String> get panelConditions => vehicleDetails.panelConditions;

  String get categoryPathLabel =>
      categoryPath.map((c) => c.nameAr).join(' > ');

  bool get canPopCategoryDrill => categoryDrillStack.isNotEmpty;

  PostListingState copyWith({
    int? currentStep,
    List<CategoryModel>? categoryPath,
    bool clearCategoryPath = false,
    List<List<CategoryModel>>? categoryDrillStack,
    bool clearCategoryDrillStack = false,
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
    String? locationAddress,
    bool clearLocationAddress = false,
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
    VehicleListingMetadata? vehicleDetails,
    RealEstateListingMetadata? realEstateDetails,
    ElectronicsListingMetadata? electronicsDetails,
    GeneralListingMetadata? generalDetails,
    TutoringListingMetadata? tutoringDetails,
    JobListingMetadata? jobDetails,
    AnimalListingMetadata? animalDetails,
    HomeServiceListingMetadata? homeServiceDetails,
    Set<String>? configuredPaintPanels,
    bool clearConfiguredPaintPanels = false,
    bool? allPartsOriginalDeclared,
    ListingContactPreference? contactPreference,
    bool clearContactPreference = false,
    ListingPackage? listingPackage,
    File? pendingVideoFile,
    File? pendingVideoThumbnail,
    int? videoDurationSeconds,
    double? videoProcessingProgress,
    bool? isVideoProcessing,
    int? freePostsUsedThisMonth,
    bool clearVideo = false,
    bool clearError = false,
    bool clearCategory = false,
    bool clearSubcategory = false,
    bool clearStep2Fields = false,
  }) {
    return PostListingState(
      currentStep: currentStep ?? this.currentStep,
      categoryPath: clearCategoryPath
          ? const []
          : (categoryPath ?? this.categoryPath),
      categoryDrillStack: clearCategoryDrillStack
          ? const []
          : (categoryDrillStack ?? this.categoryDrillStack),
      selectedCategory:
          clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      selectedSubcategory: clearSubcategory
          ? null
          : (selectedSubcategory ?? this.selectedSubcategory),
      expandedParentId: clearExpandedParent
          ? null
          : (expandedParentId ?? this.expandedParentId),
      title: clearStep2Fields ? '' : (title ?? this.title),
      description: clearStep2Fields ? '' : (description ?? this.description),
      price: clearStep2Fields ? null : (price ?? this.price),
      isNegotiable: isNegotiable ?? this.isNegotiable,
      listingType: listingType ?? this.listingType,
      condition: clearStep2Fields ? null : (condition ?? this.condition),
      governorate: governorate ?? this.governorate,
      city: city ?? this.city,
      latitude: clearLocation ? null : (latitude ?? this.latitude),
      longitude: clearLocation ? null : (longitude ?? this.longitude),
      locationAddress: clearLocation || clearLocationAddress
          ? null
          : (locationAddress ?? this.locationAddress),
      images: images ?? this.images,
      uploadedImagePaths: uploadedImagePaths ?? this.uploadedImagePaths,
      uploadIndex: uploadIndex ?? this.uploadIndex,
      uploadTotal: uploadTotal ?? this.uploadTotal,
      statusMessage: statusMessage ?? this.statusMessage,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isPublished: isPublished ?? this.isPublished,
      publishedListingId: publishedListingId ?? this.publishedListingId,
      vehicleDetails: vehicleDetails ?? this.vehicleDetails,
      realEstateDetails: realEstateDetails ?? this.realEstateDetails,
      electronicsDetails: electronicsDetails ?? this.electronicsDetails,
      generalDetails: generalDetails ?? this.generalDetails,
      tutoringDetails: tutoringDetails ?? this.tutoringDetails,
      jobDetails: jobDetails ?? this.jobDetails,
      animalDetails: animalDetails ?? this.animalDetails,
      homeServiceDetails: homeServiceDetails ?? this.homeServiceDetails,
      configuredPaintPanels: clearConfiguredPaintPanels
          ? const {}
          : (configuredPaintPanels ?? this.configuredPaintPanels),
      allPartsOriginalDeclared:
          allPartsOriginalDeclared ?? this.allPartsOriginalDeclared,
      contactPreference: clearContactPreference
          ? null
          : (contactPreference ?? this.contactPreference),
      listingPackage: listingPackage ?? this.listingPackage,
      pendingVideoFile:
          clearVideo ? null : (pendingVideoFile ?? this.pendingVideoFile),
      pendingVideoThumbnail: clearVideo
          ? null
          : (pendingVideoThumbnail ?? this.pendingVideoThumbnail),
      videoDurationSeconds: clearVideo
          ? null
          : (videoDurationSeconds ?? this.videoDurationSeconds),
      videoProcessingProgress:
          videoProcessingProgress ?? this.videoProcessingProgress,
      isVideoProcessing: isVideoProcessing ?? this.isVideoProcessing,
      freePostsUsedThisMonth:
          freePostsUsedThisMonth ?? this.freePostsUsedThisMonth,
    );
  }
}

class PostListingNotifier extends Notifier<PostListingState> {
  @override
  PostListingState build() => const PostListingState();

  void goToStep(int step) {
    state = state.copyWith(
      currentStep: step.clamp(1, state.maxStep),
      clearError: true,
    );
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
    if (state.currentStep < state.maxStep) {
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
      'locationAddress' => state.copyWith(
        locationAddress: value as String?,
        clearError: true,
      ),
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

  void setCategoryPath(List<CategoryModel> path) {
    state = state.copyWith(categoryPath: path, clearError: true);
  }

  void appendToCategoryPath(CategoryModel category) {
    state = state.copyWith(
      categoryPath: [...state.categoryPath, category],
      clearError: true,
    );
  }

  /// Sets the category at [depth] during drill-down (0 = root). Replaces the
  /// path from that depth instead of appending, so switching root categories
  /// (e.g. سكني → سيارات) does not keep the previous branch.
  void selectCategoryAtDrillDepth(int depth, CategoryModel category) {
    final current = state.categoryPath;
    final newPath = depth <= 0
        ? [category]
        : [
            ...current.sublist(0, depth.clamp(0, current.length)),
            category,
          ];
    final trimmedStack = depth < state.categoryDrillStack.length
        ? state.categoryDrillStack.sublist(0, depth)
        : state.categoryDrillStack;

    state = CategoryDetailsDefaults.withEmptyCategoryDetails(
      state.copyWith(
        categoryPath: newPath,
        categoryDrillStack: trimmedStack,
        clearCategory: true,
        clearSubcategory: true,
        clearExpandedParent: true,
        clearStep2Fields: true,
        clearError: true,
      ),
    );
  }

  void pushCategoryDrillLevel(List<CategoryModel> children) {
    if (children.isEmpty) return;
    state = state.copyWith(
      categoryDrillStack: [...state.categoryDrillStack, children],
      clearError: true,
    );
  }

  void popCategoryDrillLevel() {
    if (!state.canPopCategoryDrill) return;

    final newStack = state.categoryDrillStack.sublist(
      0,
      state.categoryDrillStack.length - 1,
    );
    final newPathLength =
        state.categoryPath.length > 0 ? state.categoryPath.length - 1 : 0;

    state = state.copyWith(
      categoryDrillStack: newStack,
      categoryPath: newPathLength > 0
          ? state.categoryPath.sublist(0, newPathLength)
          : const [],
      clearCategoryPath: newPathLength <= 0,
      clearError: true,
    );
  }

  void jumpCategoryDrillToDepth(int targetDepth) {
    if (targetDepth <= 0) {
      state = state.copyWith(
        clearCategoryPath: true,
        clearCategoryDrillStack: true,
        clearError: true,
      );
      return;
    }

    final path = state.categoryPath;
    final stack = state.categoryDrillStack;
    state = state.copyWith(
      categoryPath: path.length > targetDepth
          ? path.sublist(0, targetDepth)
          : path,
      categoryDrillStack: stack.length > targetDepth
          ? stack.sublist(0, targetDepth)
          : stack,
      clearError: true,
    );
  }

  void trimCategoryPath(int length) {
    if (length <= 0) {
      state = state.copyWith(
        clearCategoryPath: true,
        clearCategoryDrillStack: true,
        clearError: true,
      );
      return;
    }
    state = state.copyWith(
      categoryPath: state.categoryPath.sublist(0, length),
      categoryDrillStack: state.categoryDrillStack.length > length
          ? state.categoryDrillStack.sublist(0, length)
          : state.categoryDrillStack,
      clearError: true,
    );
  }

  void resetCategoryDrill() {
    state = CategoryDetailsDefaults.withEmptyCategoryDetails(
      state.copyWith(
        clearCategoryPath: true,
        clearCategoryDrillStack: true,
        clearCategory: true,
        clearSubcategory: true,
        clearExpandedParent: true,
        clearError: true,
      ),
    );
  }

  void selectLeafCategory(List<CategoryModel> fullPath) {
    if (fullPath.isEmpty) return;
    final leaf = fullPath.last;
    final electronicsKind = electronicsFormKind(fullPath);
    final electronicsDetails = electronicsKind != ElectronicsFormKind.none
        ? deriveElectronicsDetailsFromPath(fullPath, electronicsKind)
        : CategoryDetailsDefaults.electronics;
    final generalDetails = isGeneralMarketplaceCategoryPath(fullPath)
        ? initialGeneralDetailsForPath(fullPath)
        : CategoryDetailsDefaults.general;
    final tutoringDetails = isTutoringCategoryPath(fullPath)
        ? deriveTutoringDetailsFromPath(fullPath)
        : CategoryDetailsDefaults.tutoring;
    final jobDetails = isJobCategoryPath(fullPath)
        ? deriveJobDetailsFromPath(fullPath)
        : CategoryDetailsDefaults.job;
    final animalDetails = isAnimalCategoryPath(fullPath)
        ? deriveAnimalDetailsFromPath(fullPath)
        : CategoryDetailsDefaults.animal;
    final homeServiceDetails = isHomeServiceCategoryPath(fullPath)
        ? deriveHomeServiceDetailsFromPath(fullPath)
        : CategoryDetailsDefaults.homeService;

    state = CategoryDetailsDefaults.withEmptyCategoryDetails(
      state.copyWith(
        categoryPath: fullPath,
        selectedCategory: leaf,
        clearSubcategory: true,
        clearExpandedParent: true,
        clearStep2Fields: true,
        clearError: true,
      ),
      electronicsDetails: electronicsDetails,
      generalDetails: generalDetails,
      tutoringDetails: tutoringDetails,
      jobDetails: jobDetails,
      animalDetails: animalDetails,
      homeServiceDetails: homeServiceDetails,
    );
  }

  void updateRealEstateDetails(RealEstateListingMetadata details) {
    final listingType = details.offerType != null
        ? realEstateListingTypeEnum(details.offerType)
        : state.listingType;
    state = state.copyWith(
      realEstateDetails: details,
      listingType: listingType,
      clearError: true,
    );
  }

  void toggleRealEstateFeature(String feature) {
    final current = state.realEstateDetails;
    final features = [...current.features];
    if (features.contains(feature)) {
      features.remove(feature);
    } else {
      features.add(feature);
    }
    state = state.copyWith(
      realEstateDetails: current.copyWith(features: features),
      clearError: true,
    );
  }

  void syncRealEstateListingCopy() => _applyRealEstateListingCopy();

  void _applyRealEstateListingCopy() {
    if (!state.isRealEstateListing) return;
    if (state.title.trim().isNotEmpty) return;
    state = state.copyWith(
      title: buildRealEstateListingTitle(
        state.categoryPath,
        state.realEstateDetails,
      ),
      clearError: true,
    );
  }

  void updateVehicleDetails(VehicleListingMetadata details) {
    state = state.copyWith(vehicleDetails: details, clearError: true);
  }

  void setVehiclePanelCondition(String panelKey, String condition) {
    final current = Map<String, String>.from(state.vehicleDetails.panelConditions);
    if (condition == CarPaintCondition.original) {
      current.remove(panelKey);
    } else {
      current[panelKey] = condition;
    }
    final configured = {...state.configuredPaintPanels, panelKey};
    state = state.copyWith(
      vehicleDetails: state.vehicleDetails.copyWith(panelConditions: current),
      configuredPaintPanels: configured,
      allPartsOriginalDeclared: false,
      clearError: true,
    );
  }

  void setAllPartsOriginalDeclared(bool value) {
    if (value) {
      state = state.copyWith(
        vehicleDetails:
            state.vehicleDetails.copyWith(clearPanelConditions: true),
        clearConfiguredPaintPanels: true,
        allPartsOriginalDeclared: true,
        clearError: true,
      );
    } else {
      state = state.copyWith(
        allPartsOriginalDeclared: false,
        clearError: true,
      );
    }
  }

  void toggleVehicleSpec(String spec) {
    final current = state.vehicleDetails;
    final specs = [...current.selectedSpecs];
    if (specs.contains(spec)) {
      specs.remove(spec);
    } else {
      specs.add(spec);
    }
    state = state.copyWith(
      vehicleDetails: current.copyWith(selectedSpecs: specs),
      clearError: true,
    );
  }

  void updateElectronicsDetails(ElectronicsListingMetadata details) {
    state = state.copyWith(
      electronicsDetails: details,
      condition: electronicsDbCondition(details.condition),
      clearError: true,
    );
  }

  void syncElectronicsListingCopy() => _applyElectronicsListingCopy();

  void _applyElectronicsListingCopy() {
    if (!state.isElectronicsListing) return;
    if (state.title.trim().isNotEmpty) return;
    state = state.copyWith(
      title: buildElectronicsListingTitle(
        state.categoryPath,
        state.electronicsDetails,
      ),
      clearError: true,
    );
  }

  void updateGeneralDetails(GeneralListingMetadata details) {
    state = state.copyWith(
      generalDetails: details,
      condition: generalDbCondition(details.itemCondition),
      clearError: true,
    );
  }

  void syncGeneralListingCopy() => _applyGeneralListingCopy();

  void _applyGeneralListingCopy() {
    if (!state.isGeneralMarketplaceListing) return;
    if (state.title.trim().isNotEmpty) return;
    state = state.copyWith(
      title: buildGeneralListingTitle(state.categoryPath, state.generalDetails),
      clearError: true,
    );
  }

  void updateTutoringDetails(TutoringListingMetadata details) {
    state = state.copyWith(
      tutoringDetails: details,
      price: details.pricePerHour?.toDouble(),
      clearError: true,
    );
  }

  void toggleTutoringStage(String stage) {
    final current = state.tutoringDetails;
    final stages = [...current.stages];
    if (stages.contains(stage)) {
      stages.remove(stage);
    } else {
      stages.add(stage);
    }
    updateTutoringDetails(current.copyWith(stages: stages));
  }

  void syncTutoringListingCopy() => _applyTutoringListingCopy();

  void _applyTutoringListingCopy() {
    if (!state.isTutoringListing) return;
    state = state.copyWith(
      title: state.title.trim().isEmpty
          ? buildTutoringListingTitle(
              state.categoryPath,
              state.tutoringDetails,
            )
          : state.title,
      price: state.tutoringDetails.pricePerHour?.toDouble(),
      clearError: true,
    );
  }

  void updateJobDetails(JobListingMetadata details) {
    state = state.copyWith(
      jobDetails: details,
      price: details.salaryMin?.toDouble(),
      clearError: true,
    );
  }

  void toggleJobBenefit(String benefit) {
    final current = state.jobDetails;
    final benefits = [...current.benefits];
    if (benefits.contains(benefit)) {
      benefits.remove(benefit);
    } else {
      benefits.add(benefit);
    }
    updateJobDetails(current.copyWith(benefits: benefits));
  }

  void syncJobListingCopy() => _applyJobListingCopy();

  void _applyJobListingCopy() {
    if (!state.isJobListing) return;
    state = state.copyWith(
      title: state.title.trim().isEmpty
          ? buildJobListingTitle(state.categoryPath, state.jobDetails)
          : state.title,
      price: state.jobDetails.salaryMin?.toDouble(),
      clearError: true,
    );
  }

  void updateAnimalDetails(AnimalListingMetadata details) {
    state = state.copyWith(animalDetails: details, clearError: true);
  }

  void syncAnimalListingCopy() => _applyAnimalListingCopy();

  void _applyAnimalListingCopy() {
    if (!state.isAnimalListing) return;
    if (state.title.trim().isNotEmpty) return;
    final details =
        animalDetailsForStorage(state.categoryPath, state.animalDetails);
    state = state.copyWith(
      title: buildAnimalListingTitle(state.categoryPath, details),
      clearError: true,
    );
  }

  void updateHomeServiceDetails(HomeServiceListingMetadata details) {
    state = state.copyWith(
      homeServiceDetails: details,
      price: details.salaryExpected?.toDouble(),
      clearError: true,
    );
  }

  void toggleHomeServiceLanguage(String language) {
    final current = state.homeServiceDetails;
    final languages = [...current.languages];
    if (languages.contains(language)) {
      languages.remove(language);
    } else {
      languages.add(language);
    }
    updateHomeServiceDetails(current.copyWith(languages: languages));
  }

  void syncHomeServiceListingCopy() => _applyHomeServiceListingCopy();

  void _applyHomeServiceListingCopy() {
    if (!state.isHomeServiceListing) return;
    final details =
        homeServiceDetailsForStorage(state.categoryPath, state.homeServiceDetails);
    state = state.copyWith(
      title: state.title.trim().isEmpty
          ? buildHomeServiceListingTitle(state.categoryPath, details)
          : state.title,
      price: details.salaryExpected?.toDouble(),
      clearError: true,
    );
  }

  void syncVehicleListingCopy() => _applyVehicleListingCopy();

  void _applyVehicleListingCopy() {
    if (!state.isVehicleListing) return;
    if (state.title.trim().isNotEmpty) return;
    state = state.copyWith(
      title: buildVehicleListingTitle(state.categoryPath, state.vehicleDetails),
      clearError: true,
    );
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

  Future<void> addImages(List<File> files) async {
    if (files.isEmpty) return;
    var images = [...state.images];
    for (final file in files) {
      if (images.length >= AppConstants.maxListingPhotos) break;
      try {
        final compressed = await compressListingImage(file);
        images = [...images, compressed];
      } catch (_) {
        state = state.copyWith(error: 'تعذّر معالجة الصورة');
        return;
      }
    }
    state = state.copyWith(images: images, clearError: true);
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

  Future<void> setPendingVideo(File file) async {
    if (!state.listingPackage.allowsListingVideo) return;

    state = state.copyWith(
      isVideoProcessing: true,
      videoProcessingProgress: 0.05,
      clearError: true,
    );

    try {
      final videoService = ref.read(videoServiceProvider);
      state = state.copyWith(videoProcessingProgress: 0.15);
      final validation = await videoService.validateVideo(file);
      if (!validation.isValid) {
        throw VideoUploadException(
          validation.errorMessage ?? 'فيديو غير صالح',
        );
      }

      state = state.copyWith(videoProcessingProgress: 0.45);
      final thumbnail = await videoService.generateThumbnail(file);

      state = state.copyWith(
        pendingVideoFile: file,
        pendingVideoThumbnail: thumbnail,
        videoDurationSeconds: validation.durationSeconds,
        isVideoProcessing: false,
        videoProcessingProgress: 1,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isVideoProcessing: false,
        videoProcessingProgress: 0,
        error: e is VideoUploadException ? e.message : 'تعذّر معالجة الفيديو',
      );
      rethrow;
    }
  }

  void removeVideo() {
    state = state.copyWith(clearVideo: true, clearError: true);
  }

  void clearLocation() {
    state = state.copyWith(clearLocation: true);
  }

  void setContactPreference(ListingContactPreference preference) {
    state = state.copyWith(contactPreference: preference, clearError: true);
  }

  void setListingPackage(ListingPackage package) {
    state = state.copyWith(
      listingPackage: package,
      clearVideo: !package.allowsListingVideo,
      clearError: true,
    );
  }

  Future<void> refreshFreePostQuota() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    try {
      final used =
          await ref.read(listingsRepositoryProvider).fetchMonthlyFreePostCount(
                userId,
              );
      state = state.copyWith(freePostsUsedThisMonth: used);
    } catch (e, stackTrace) {
      debugPrint('refreshFreePostQuota failed: $e\n$stackTrace');
    }
  }

  void confirmListingPackage() {
    state = state.copyWith(clearError: true);
    nextStep();
  }

  String? _validateCategory() {
    if (state.selectedCategory == null || state.categoryPath.isEmpty) {
      return 'اختر الفئة';
    }
    return null;
  }

  String? validateStep(int step) {
    if (state.isVehicleListing) {
      return switch (step) {
        1 => _validateCategory(),
        2 => _validateDetails(),
        3 => null,
        4 => _validateLocation(),
        5 => _validatePhotos(),
        6 => _validateContactPreferences(),
        7 => null,
        8 => null,
        _ => null,
      };
    }
    return switch (step) {
      1 => _validateCategory(),
      2 => _validateDetails(),
      3 => _validateLocation(),
      4 => _validatePhotos(),
      5 => _validateContactPreferences(),
      6 => null,
      7 => null,
      _ => null,
    };
  }

  String? _validateContactPreferences() {
    if (state.contactPreference == null) {
      return 'اختر تفضيل التواصل';
    }
    return null;
  }

  String? _validateLocation() {
    if (state.governorate == null || state.governorate!.trim().isEmpty) {
      return 'اختر المحافظة';
    }
    return null;
  }

  String _cityForListingDb() {
    final gov = state.governorate;
    if (gov != null && gov.trim().isNotEmpty) {
      return governorateNameAr(gov);
    }
    return '—';
  }

  String? _validatePhotos() {
    if (state.images.isEmpty) return 'يرجى إضافة صورة واحدة على الأقل';
    return null;
  }

  String? _validateDetails() {
    final titleError = _validateTitleFields();
    if (titleError != null) return titleError;

    if (state.isVehicleListing) return _validateVehicleDetails();
    if (state.isRealEstateListing) return _validateRealEstateDetails();
    if (state.isElectronicsListing) return _validateElectronicsDetails();
    if (state.isGeneralMarketplaceListing) return _validateGeneralDetails();
    if (state.isTutoringListing) return _validateTutoringDetails();
    if (state.isJobListing) return _validateJobDetails();
    if (state.isAnimalListing) return _validateAnimalDetails();
    if (state.isHomeServiceListing) return _validateHomeServiceDetails();
    return _validateGenericDetails();
  }

  String? _validateTitleFields() {
    if (state.title.trim().length < 5) {
      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
    }
    if (state.title.trim().length > 100) {
      return 'العنوان طويل جداً (100 حرف كحد أقصى)';
    }
    if (state.description.trim().length > 2000) {
      return 'الوصف طويل جداً (2000 حرف كحد أقصى)';
    }
    return null;
  }

  String? _validateGenericDetails() {
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    if (state.condition == null) return 'اختر حالة المنتج';
    return null;
  }

  String? _validateVehicleDetails() {
    final vehicle = state.vehicleDetails;
    if (state.condition == null) return 'اختر الحالة';
    if (vehicle.fuel == null || vehicle.fuel!.isEmpty) {
      return 'اختر نوع الوقود';
    }
    if (vehicle.transmission == null || vehicle.transmission!.isEmpty) {
      return 'اختر ناقل الحركة';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    return null;
  }

  String? _validateRealEstateDetails() {
    final details = state.realEstateDetails;
    if (details.propertyType == null || details.propertyType!.isEmpty) {
      return 'اختر نوع العقار';
    }
    if (details.offerType == null || details.offerType!.isEmpty) {
      return 'اختر نوع العرض';
    }
    if (details.areaSqm == null || details.areaSqm! <= 0) {
      return 'أدخل المساحة بالمتر المربع';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    return null;
  }

  String? _validateElectronicsDetails() {
    final details = state.electronicsDetails;
    if (details.condition == null || details.condition!.isEmpty) {
      return 'اختر الحالة';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    return null;
  }

  String? _validateGeneralDetails() {
    final details = state.generalDetails;
    if (details.itemCondition == null || details.itemCondition!.isEmpty) {
      return 'اختر الحالة';
    }
    if (details.deliveryAvailable == true &&
        (details.deliveryCost == null || details.deliveryCost!.isEmpty)) {
      return 'اختر تكلفة التوصيل';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    return null;
  }

  String? _validateTutoringDetails() {
    final details = state.tutoringDetails;
    if (details.subject == null || details.subject!.isEmpty) {
      return 'اختر المادة';
    }
    if (details.stages.isEmpty) return 'اختر المرحلة الدراسية';
    if (details.sessionType == null || details.sessionType!.isEmpty) {
      return 'اختر طريقة التدريس';
    }
    if (details.pricePerHour == null || details.pricePerHour! <= 0) {
      return 'أدخل سعراً صالحاً للساعة';
    }
    return null;
  }

  String? _validateJobDetails() {
    final details = state.jobDetails;
    if (details.jobType == null || details.jobType!.isEmpty) {
      return 'اختر نوع الدوام';
    }
    if (details.sector == null || details.sector!.isEmpty) {
      return 'اختر القطاع';
    }
    if (details.salaryMin == null || details.salaryMin! <= 0) {
      return 'أدخل الراتب الأدنى';
    }
    if (details.salaryMax != null && details.salaryMax! < details.salaryMin!) {
      return 'الراتب الأعلى يجب أن يكون أكبر من الأدنى';
    }
    return null;
  }

  String? _validateAnimalDetails() {
    final type =
        deriveAnimalDetailsFromPath(state.categoryPath).animalType;
    if (type == null || type.isEmpty) {
      return 'اختر نوع الحيوان من الفئات';
    }
    if (state.price == null || state.price! <= 0) return 'أدخل سعراً صالحاً';
    return null;
  }

  String? _validateHomeServiceDetails() {
    final serviceType =
        deriveHomeServiceDetailsFromPath(state.categoryPath).serviceType;
    if (serviceType == null || serviceType.isEmpty) {
      return 'اختر نوع الخدمة من الفئات';
    }
    final details = state.homeServiceDetails;
    if (details.availability == null || details.availability!.isEmpty) {
      return 'اختر أوقات العمل';
    }
    if (details.salaryExpected == null || details.salaryExpected! <= 0) {
      return 'أدخل الراتب المتوقع';
    }
    return null;
  }

  Map<String, dynamic>? _buildListingMetadata() {
    Map<String, dynamic>? base;
    if (state.isVehicleListing) {
      base = vehicleMetadataForStorage(state.vehicleDetails);
    } else if (state.isRealEstateListing) {
      base = realEstateMetadataForStorage(state.realEstateDetails);
    } else if (state.isElectronicsListing) {
      base = electronicsMetadataForStorage(state.electronicsDetails);
    } else if (state.isGeneralMarketplaceListing) {
      base = generalMetadataForStorage(state.generalDetails);
    } else if (state.isTutoringListing) {
      base = tutoringMetadataForStorage(state.tutoringDetails);
    } else if (state.isJobListing) {
      base = jobMetadataForStorage(state.jobDetails);
    } else if (state.isAnimalListing) {
      base = animalMetadataForStorage(
        animalDetailsForStorage(state.categoryPath, state.animalDetails),
      );
    } else if (state.isHomeServiceListing) {
      base = homeServiceMetadataForStorage(
        homeServiceDetailsForStorage(
          state.categoryPath,
          state.homeServiceDetails,
        ),
      );
    }
    return _withListingPackageMetadata(_withContactPreferenceMetadata(base));
  }

  Map<String, dynamic>? _withContactPreferenceMetadata(
    Map<String, dynamic>? metadata,
  ) {
    final preference = state.contactPreference;
    if (preference == null && (metadata == null || metadata.isEmpty)) {
      return metadata;
    }
    final merged = Map<String, dynamic>.from(metadata ?? {});
    if (preference != null) {
      merged['contact_preference'] = preference.value;
    }
    return merged.isEmpty ? null : merged;
  }

  Map<String, dynamic>? _withListingPackageMetadata(
    Map<String, dynamic>? metadata,
  ) {
    final merged = Map<String, dynamic>.from(metadata ?? {});
    merged['listing_package'] = state.listingPackage.value;
    return merged;
  }

  String _dbListingType() {
    if (state.isRealEstateListing) {
      return realEstateDbListingType(state.realEstateDetails.offerType);
    }
    return state.listingType.value;
  }

  ListingCondition? _publishCondition() {
    if (state.isRealEstateListing ||
        state.isTutoringListing ||
        state.isJobListing ||
        state.isHomeServiceListing ||
        state.isAnimalListing) {
      return null;
    }
    if (state.isElectronicsListing) {
      return electronicsDbCondition(state.electronicsDetails.condition);
    }
    if (state.isGeneralMarketplaceListing) {
      return generalDbCondition(state.generalDetails.itemCondition);
    }
    return state.condition;
  }

  bool _requiresPublishCondition() {
    return !state.isRealEstateListing &&
        !state.isTutoringListing &&
        !state.isJobListing &&
        !state.isHomeServiceListing &&
        !state.isAnimalListing;
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

    for (var step = 1; step <= state.lastStepBeforeReview; step++) {
      final stepError = validateStep(step);
      if (stepError != null) {
        state = state.copyWith(error: stepError);
        return null;
      }
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      if (state.isVehicleListing) {
        _applyVehicleListingCopy();
      } else if (state.isRealEstateListing) {
        _applyRealEstateListingCopy();
      } else if (state.isElectronicsListing) {
        _applyElectronicsListingCopy();
      } else if (state.isGeneralMarketplaceListing) {
        _applyGeneralListingCopy();
      } else if (state.isTutoringListing) {
        _applyTutoringListingCopy();
      } else if (state.isJobListing) {
        _applyJobListingCopy();
      } else if (state.isAnimalListing) {
        _applyAnimalListingCopy();
      } else if (state.isHomeServiceListing) {
        _applyHomeServiceListingCopy();
      }

      final imagePaths = state.uploadedImagePaths.isNotEmpty
          ? state.uploadedImagePaths
          : await uploadImages(userId);

      final metadata = _buildListingMetadata();
      final condition = _publishCondition();
      if (_requiresPublishCondition() && condition == null) {
        state = state.copyWith(
          isLoading: false,
          error: 'اختر حالة المنتج',
        );
        return null;
      }

      if (kDebugMode) {
        debugPrint(
          'publishListing submit: category=${state.effectiveCategory!.id} '
          'contactPreference=${state.contactPreference?.value} metadata=$metadata',
        );
      }

      final id = await ref.read(listingsRepositoryProvider).createListingRecord(
            userId: userId,
            categoryId: state.effectiveCategory!.id,
            title: state.title.trim(),
            description: state.description.trim(),
            price: state.price!,
            isNegotiable: state.isNegotiable,
            condition: condition,
            city: _cityForListingDb(),
            governorate: state.governorate!,
            latitude: state.latitude,
            longitude: state.longitude,
            locationAddress: state.locationAddress,
            imageStoragePaths: imagePaths,
            asDraft: false,
            listingType: _dbListingType(),
            metadata: metadata,
            contactPreference: state.contactPreference,
            listingPackage: state.listingPackage,
          );

      if (state.pendingVideoFile != null &&
          state.listingPackage.allowsListingVideo) {
        state = state.copyWith(
          statusMessage: 'جاري رفع الفيديو... 0%',
        );
        final upload = await ref.read(videoServiceProvider).uploadVideo(
              videoFile: state.pendingVideoFile!,
              listingId: id,
              onProgress: (p) {
                state = state.copyWith(
                  statusMessage:
                      'جاري رفع الفيديو... ${(p * 100).round()}%',
                );
              },
            );
        await ref.read(listingsRepositoryProvider).updateListingVideo(
              listingId: id,
              videoUrl: upload.videoUrl,
              thumbnailUrl: upload.thumbnailUrl,
              durationSeconds: upload.durationSeconds,
            );
      }

      final paidStandard = state.standardRequiresPaidPublish;
      final packageType = state.listingPackage.purchasePackageTypeFor(
        paidStandard: paidStandard,
      );
      if (packageType != null) {
        try {
          final profile = await ref.read(currentProfileProvider.future);
          final email =
              ref.read(supabaseClientProvider).auth.currentUser?.email;
          final price = ListingPackageConfig.purchasePriceIqd(
            state.listingPackage,
            standardOverQuota: paidStandard,
          );
          await ref.read(listingsRepositoryProvider).recordListingPurchase(
                userId: userId,
                listingId: id,
                packageType: packageType,
                price: price,
                userName: profile?.fullName.trim().isNotEmpty == true
                    ? profile!.fullName
                    : '—',
                userPhone: profile?.phone,
                userEmail: email,
              );
        } catch (e, stackTrace) {
          // Listing is already saved; package activation can be retried by admin.
          debugPrint(
            'recordListingPurchase failed for listing $id: $e\n$stackTrace',
          );
        }
      } else if (state.listingPackage == ListingPackage.standard &&
          !paidStandard) {
        try {
          await ref
              .read(listingsRepositoryProvider)
              .incrementMonthlyFreePostCount(userId);
        } catch (e, stackTrace) {
          debugPrint(
            'incrementMonthlyFreePostCount failed for $userId: $e\n$stackTrace',
          );
        }
      }

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
    } catch (e, stackTrace) {
      debugPrint('publishListing failed: $e\n$stackTrace');
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

      if (state.isVehicleListing) {
        _applyVehicleListingCopy();
      } else if (state.isRealEstateListing) {
        _applyRealEstateListingCopy();
      } else if (state.isElectronicsListing) {
        _applyElectronicsListingCopy();
      } else if (state.isGeneralMarketplaceListing) {
        _applyGeneralListingCopy();
      } else if (state.isTutoringListing) {
        _applyTutoringListingCopy();
      } else if (state.isJobListing) {
        _applyJobListingCopy();
      } else if (state.isAnimalListing) {
        _applyAnimalListingCopy();
      } else if (state.isHomeServiceListing) {
        _applyHomeServiceListingCopy();
      }

      final metadata = _buildListingMetadata();

      final id = await ref.read(listingsRepositoryProvider).createListingRecord(
            userId: userId,
            categoryId: state.effectiveCategory!.id,
            title: state.title.trim().isEmpty ? 'مسودة' : state.title.trim(),
            description: state.description.trim(),
            price: state.price ?? 0,
            isNegotiable: state.isNegotiable,
            condition: _publishCondition(),
            city: _cityForListingDb(),
            governorate: state.governorate ?? 'baghdad',
            latitude: state.latitude,
            longitude: state.longitude,
            locationAddress: state.locationAddress,
            imageStoragePaths: imagePaths,
            asDraft: true,
            listingType: _dbListingType(),
            metadata: metadata,
            contactPreference: state.contactPreference,
            listingPackage: state.listingPackage,
          );

      state = state.copyWith(
        isLoading: false,
        isPublished: true,
        publishedListingId: id,
        statusMessage: null,
      );
      invalidateMyListingsProviders(ref);
      return id;
    } catch (e, stackTrace) {
      debugPrint('saveDraft failed: $e\n$stackTrace');
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
