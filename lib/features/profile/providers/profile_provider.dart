import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_reset.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/listing_model.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_stats_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../listings/data/listings_repository.dart';
import '../data/profile_repository.dart';

export '../data/profile_repository.dart';

const _myListingStatuses = ['active', 'pending', 'sold', 'deleted'];

final sellerProfileProvider =
    FutureProvider.family<ProfileModel?, String>((ref, userId) async {
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

final profileStatsProvider =
    FutureProvider.family<ProfileStats, String>((ref, userId) async {
  return ref.watch(profileRepositoryProvider).getProfileStats(userId);
});

final sellerListingsPreviewProvider =
    FutureProvider.family<List<ListingModel>, String>((ref, userId) async {
  return ref.watch(listingsRepositoryProvider).getSellerListings(
        userId,
        limit: 6,
      );
});

final myListingsProvider =
    FutureProvider.family<List<ListingModel>, String>((ref, status) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return [];
  return ref
      .watch(listingsRepositoryProvider)
      .fetchMyListingsByStatus(userId, status);
});

final myListingsCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return {};
  return ref.watch(listingsRepositoryProvider).fetchMyListingsCounts(userId);
});

class MyListingsLoadedTabsNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => {0};

  void markLoaded(int index) => state = {...state, index};
}

final myListingsLoadedTabsProvider =
    NotifierProvider<MyListingsLoadedTabsNotifier, Set<int>>(
  MyListingsLoadedTabsNotifier.new,
);

String myListingStatusForTab(int index) => _myListingStatuses[index];

void invalidateMyListingsProviders(Ref ref) {
  ref.invalidate(myListingsCountsProvider);
  for (final status in _myListingStatuses) {
    ref.invalidate(myListingsProvider(status));
  }
}

class ProfileNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<Result<ProfileModel>> updateProfile(ProfileModel updated) async {
    state = const AsyncLoading();
    try {
      final saved =
          await ref.read(profileRepositoryProvider).updateProfile(updated);
      ref.invalidate(currentProfileProvider);
      ref.invalidate(myProfileProvider);
      state = const AsyncData(null);
      return Success(saved);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Failure('$e');
    }
  }

  Future<Result<String>> updateAvatar(File image) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return const Failure('يجب تسجيل الدخول أولاً');
    }
    state = const AsyncLoading();
    try {
      final url = await ref.read(profileRepositoryProvider).updateAvatar(
            userId: userId,
            image: image,
          );
      ref.invalidate(currentProfileProvider);
      state = const AsyncData(null);
      return Success(url);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return Failure('$e');
    }
  }

  Future<Result<void>> removeAvatar() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return const Failure('يجب تسجيل الدخول أولاً');
    }
    try {
      await ref.read(profileRepositoryProvider).removeAvatar(userId);
      ref.invalidate(currentProfileProvider);
      return const Success(null);
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<void>> deleteAccount() async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      return const Failure('يجب تسجيل الدخول أولاً');
    }
    try {
      await ref.read(profileRepositoryProvider).deleteAccount(userId);
      invalidateSessionProviders(ref);
      ref.read(authNotifierProvider.notifier).enterGuestMode();
      return const Success(null);
    } catch (e) {
      return Failure('$e');
    }
  }

  Future<Result<bool>> signOut() async {
    final result = await ref.read(authNotifierProvider.notifier).signOut();
    if (result is Success) {
      invalidateSessionProviders(ref);
    }
    return result;
  }
}

final profileNotifierProvider =
    NotifierProvider<ProfileNotifier, AsyncValue<void>>(ProfileNotifier.new);

class ProfileSetupLoadingNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setLoading(bool value) => state = value;
}

final profileSetupLoadingProvider =
    NotifierProvider<ProfileSetupLoadingNotifier, bool>(
  ProfileSetupLoadingNotifier.new,
);

class ProfileGovernorateNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? value) => state = value;
}

final profileGovernorateProvider =
    NotifierProvider<ProfileGovernorateNotifier, String?>(
  ProfileGovernorateNotifier.new,
);
