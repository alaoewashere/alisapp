import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/public_profiles_query.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/username_utils.dart';
import '../../../core/utils/validators.dart';
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
    final currentId = _client.auth.currentUser?.id;
    if (currentId == userId) {
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

    final publicRows = await fetchPublicProfiles(_client, [userId]);
    if (publicRows.isEmpty) return null;
    return ProfileModel.fromJson(publicRows.first);
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

  Future<ProfileModel> updateAvatarSeed(String userId, String seed) async {
    final data = await _client
        .from('profiles')
        .update({
          'avatar_seed': seed,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<void> deleteAccount(String userId) async {
    await _client.from('profiles').update({
      'is_deleted': true,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', userId);
    await _client.auth.signOut();
  }

  /// Returns whether [username] is free (case-insensitive), optionally
  /// ignoring [excludeUserId] (for edit-profile checks).
  Future<bool> isUsernameAvailable(
    String username, {
    String? excludeUserId,
  }) async {
    final normalized = normalizeUsername(username);
    if (!isValidUsernameFormat(normalized)) return false;

    final available = await _client.rpc(
      'check_username_available',
      params: {
        'p_username': normalized,
        if (excludeUserId != null) 'p_exclude_user_id': excludeUserId,
      },
    );
    return available == true;
  }

  Future<ProfileModel> updateUsername(String userId, String username) async {
    final normalized = normalizeUsername(username);
    final data = await _client
        .from('profiles')
        .update({
          'username': normalized,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', userId)
        .select()
        .single();
    return ProfileModel.fromJson(data);
  }

  Future<Result<bool>> sendProfilePhoneOtp(String phoneE164) async {
    try {
      final phone = Validators.normalizeE164(phoneE164);
      final response = await _client.functions.invoke(
        'send-whatsapp-otp',
        body: {'phone': phone, 'purpose': 'profile'},
      );
      if (kDebugMode) {
        debugPrint(
          'sendProfilePhoneOtp ← ${response.status} ${response.data}',
        );
      }
      if (response.status == 200) {
        return const Success(true);
      }
      return Failure(_profileOtpSendErrorMessage(response.data));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('sendProfilePhoneOtp error: $e');
      }
      return Failure('فشل إرسال الرمز، حاول مجدداً', cause: e);
    }
  }

  String _profileOtpSendErrorMessage(Object? data) {
    if (data is Map) {
      final code = data['error']?.toString() ?? '';
      switch (code) {
        case 'invalid_phone':
          return 'رقم الهاتف غير صحيح';
        case 'unauthorized':
          return 'يجب تسجيل الدخول أولاً';
        case 'rate_limited':
        case 'rate_limited_phone':
        case 'rate_limited_ip':
          return 'تجاوزت الحد المسموح، حاول لاحقاً';
        case 'send_failed':
        case 'twilio_not_configured':
          return 'تعذّر إرسال الرمز عبر واتساب';
        case 'store_failed':
          return 'تعذّر حفظ الرمز، حاول مجدداً';
      }
    }
    return 'فشل إرسال الرمز، حاول مجدداً';
  }

  Future<Result<bool>> verifyProfilePhoneOtp({
    required String phoneE164,
    required String otp,
  }) async {
    try {
      final phone = Validators.normalizeE164(phoneE164);
      final response = await _client.functions.invoke(
        'verify-whatsapp-otp',
        body: {
          'phone': phone,
          'code': otp.trim(),
          'purpose': 'profile',
        },
      );
      final data = response.data;
      if (response.status == 200 &&
          data is Map &&
          data['status'] == 'approved') {
        return const Success(true);
      }
      if (data is Map &&
          (data['status'] == 'expired' || data['error'] == 'expired')) {
        return const Failure('انتهت صلاحية الرمز، أعد الإرسال');
      }
      return const Failure('الرمز غير صحيح');
    } catch (e) {
      return const Failure('الرمز غير صحيح');
    }
  }
}
