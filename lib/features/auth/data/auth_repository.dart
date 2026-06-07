import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/profile_model.dart';
import '../domain/auth_result.dart';
import 'auth_errors.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? getSession() => _client.auth.currentSession;

  Future<Result<bool>> sendOTP(String phoneE164) async {
    try {
      final phone = Validators.normalizeE164(phoneE164);
      if (kDebugMode) {
        debugPrint('sendOTP → $phone');
      }
      await _client.auth.signInWithOtp(
        phone: phone,
        channel: OtpChannel.sms,
        shouldCreateUser: true,
      );
      if (kDebugMode) {
        debugPrint('sendOTP ← accepted by Supabase (check SMS provider if no text arrives)');
      }
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    }
  }

  Future<Result<AuthResult>> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    try {
      final e164 = Validators.normalizeE164(phone);
      final response = await _client.auth.verifyOTP(
        phone: e164,
        token: otp.trim(),
        type: OtpType.sms,
      );

      Session? session = response.session;
      for (var i = 0; i < 3; i++) {
        session ??= _client.auth.currentSession;
        if (session != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (session == null) {
        if (kDebugMode) {
          debugPrint('verifyOTP: session not established after retries');
        }
        return const Failure('تعذّر إنشاء الجلسة. حاول مرة أخرى.');
      }

      final user = session.user;
      if (kDebugMode) {
        debugPrint('verifyOTP: session established for ${user.id}');
      }

      final profile = await _fetchProfile(user.id);
      final isNewUser = profile == null || !profile.isComplete;

      return Success(
        AuthResult(user: user, isNewUser: isNewUser),
      );
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('رمز التحقق غير صحيح أو منتهي الصلاحية.', cause: e);
    }
  }

  Future<Result<bool>> signInWithGoogle() async {
    try {
      if (kDebugMode) {
        debugPrint('signInWithGoogle → launching OAuth');
      }
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: AppConstants.authRedirectUri,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    }
  }

  Future<Result<bool>> signOut() async {
    try {
      await _client.auth.signOut();
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(e.message, cause: e);
    } catch (e) {
      return Failure('تعذّر تسجيل الخروج.', cause: e);
    }
  }

  Future<Result<ProfileModel>> createProfile(ProfileModel profile) async {
    try {
      final userId = _client.auth.currentSession?.user.id ??
          _client.auth.currentUser?.id;
      if (userId == null) {
        return const Failure('يجب تسجيل الدخول أولاً');
      }

      final data = await _client
          .from('profiles')
          .upsert({
            ...profile.toInsertJson(),
            'id': userId,
          })
          .select()
          .single();
      return Success(ProfileModel.fromJson(data));
    } on PostgrestException catch (e) {
      if (e.code == '42501' || e.message.toLowerCase().contains('jwt')) {
        return const Failure('يجب تسجيل الدخول أولاً');
      }
      return Failure(e.message, cause: e);
    } catch (e) {
      return Failure('تعذّر حفظ الملف الشخصي.', cause: e);
    }
  }

  Future<Result<String>> uploadAvatar({
    required String userId,
    required List<int> bytes,
    required String fileExtension,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final path = '$userId/avatar.$fileExtension';
      await _client.storage.from('avatars').uploadBinary(
            path,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              upsert: true,
              contentType: _mimeForExtension(fileExtension),
            ),
          );
      onProgress?.call(1.0);
      final url = _client.storage.from('avatars').getPublicUrl(path);
      return Success(url);
    } on StorageException catch (e) {
      return Failure(e.message, cause: e);
    } catch (e) {
      return Failure('تعذّر رفع الصورة.', cause: e);
    }
  }

  Future<ProfileModel?> _fetchProfile(String userId) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();
    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  String _mimeForExtension(String ext) {
    return switch (ext.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
  }
}
