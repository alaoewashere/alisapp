import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/models/profile_stats_model.dart';
import '../../auth/data/auth_repository.dart';
import '../../listings/data/listings_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(
    ref.watch(supabaseClientProvider),
    ref.watch(authRepositoryProvider),
    ref.watch(listingsRepositoryProvider),
  );
});

final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final userId = ref.watch(currentUserIdProvider);
  if (userId == null) return null;
  return ref.watch(profileRepositoryProvider).getProfile(userId);
});

/// Alias matching spec naming.
final myProfileProvider = currentProfileProvider;

final profileCompleteProvider = Provider<bool>((ref) {
  final profile = ref.watch(currentProfileProvider);
  return profile.maybeWhen(
    data: (p) => p?.isComplete ?? false,
    orElse: () => false,
  );
});

class ProfileRepository {
  ProfileRepository(this._client, this._authRepo, this._listingsRepo);

  final SupabaseClient _client;
  final AuthRepository _authRepo;
  final ListingsRepository _listingsRepo;

  Future<ProfileModel?> getProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    final profile = ProfileModel.fromJson(data);
    if (profile.isDeleted) return null;
    return profile;
  }

  Future<ProfileModel> updateProfile(ProfileModel profile) async {
    final data = await _client
        .from('profiles')
        .update(profile.toUpdateJson())
        .eq('id', profile.id)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<ProfileStats> getProfileStats(String userId) async {
    final profile = await getProfile(userId);
    final counts = await _listingsRepo.fetchMyListingsCounts(userId);
    final totalViews = await _listingsRepo.sumViewsForUser(userId);

    return ProfileStats(
      totalListings: counts.values.fold(0, (a, b) => a + b),
      activeListings: counts['active'] ?? 0,
      totalViews: totalViews,
      memberSince: profile?.createdAt ?? DateTime.now(),
    );
  }

  Future<String> updateAvatar({
    required String userId,
    required File image,
  }) async {
    final ext = image.path.split('.').last.toLowerCase();
    final bytes = await image.readAsBytes();
    final result = await _authRepo.uploadAvatar(
      userId: userId,
      bytes: bytes,
      fileExtension: ext,
    );
    switch (result) {
      case Success(:final value):
        await _client.from('profiles').update({
          'avatar_url': value,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', userId);
        return value;
      case Failure(:final message):
        throw Exception(message);
    }
  }

  Future<void> removeAvatar(String userId) async {
    await _client.from('profiles').update({
      'avatar_url': null,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
  }

  Future<void> deleteAccount(String userId) async {
    await _client.from('profiles').update({
      'is_deleted': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
    await _client.auth.signOut();
  }
}
