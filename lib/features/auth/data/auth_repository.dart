import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/username_utils.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/profile_model.dart';
import '../domain/auth_result.dart';
import 'apple_sign_in.dart';
import 'auth_errors.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(supabaseClientProvider));
});

class AuthRepository {
  AuthRepository(this._client);

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Session? getSession() => _client.auth.currentSession;

  Future<Result<bool>> sendWhatsAppOtp(
    String phoneE164, {
    String? purpose,
  }) async {
    try {
      final phone = Validators.normalizeE164(phoneE164);
      if (kDebugMode) {
        debugPrint('sendWhatsAppOtp → $phone purpose=$purpose');
      }
      final response = await _client.functions.invoke(
        'send-whatsapp-otp',
        body: {
          'phone': phone,
          if (purpose != null) 'purpose': purpose,
        },
      );
      if (kDebugMode) {
        debugPrint(
          'sendWhatsAppOtp ← status=${response.status} data=${response.data}',
        );
      }
      if (response.status == 200) {
        if (kDebugMode) {
          debugPrint('sendWhatsAppOtp ← WhatsApp OTP dispatched');
        }
        return const Success(true);
      }
      return Failure(_whatsappOtpSendErrorMessage(response));
    } on FunctionException catch (e) {
      if (kDebugMode) {
        debugPrint(
          'sendWhatsAppOtp FunctionException: status=${e.status} details=${e.details}',
        );
      }
      return Failure(
        _whatsappOtpSendErrorMessage(
          FunctionResponse(data: e.details, status: e.status),
        ),
        cause: e,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('sendWhatsAppOtp error: $e');
      }
      return Failure('فشل إرسال الرمز، حاول مجدداً', cause: e);
    }
  }

  String _whatsappOtpSendErrorMessage(FunctionResponse response) {
    final data = _coerceResponseMap(response.data);
    if (data != null) {
      final error = data['error'] as String?;
      if (error == 'rate_limited' ||
          error == 'rate_limited_phone' ||
          error == 'rate_limited_ip' ||
          error == 'throttle_check_failed' ||
          error == 'throttle_record_failed') {
        return 'تم إرسال عدة رموز. انتظر قليلاً ثم حاول مجدداً';
      }
      if (error == 'invalid_phone') {
        return 'رقم الهاتف غير صالح';
      }
      if (error == 'twilio_not_configured' || error == 'server_misconfigured') {
        return 'خدمة واتساب غير مهيأة حالياً';
      }
      if (error == 'send_failed') {
        return 'فشل إرسال الرمز عبر واتساب، حاول مجدداً';
      }

      final twilioCode = data['code'];
      final codeNum = twilioCode is int
          ? twilioCode
          : int.tryParse(twilioCode?.toString() ?? '');
      if (codeNum == 60203 || codeNum == 20429) {
        return 'تم إرسال عدة رموز. انتظر قليلاً ثم حاول مجدداً';
      }
      if (codeNum == 21211 || codeNum == 60200 || codeNum == 63016) {
        return 'رقم الهاتف غير صالح لإرسال واتساب';
      }
    }
    if (response.status == 429) {
      return 'تم إرسال عدة رموز. انتظر قليلاً ثم حاول مجدداً';
    }
    return 'فشل إرسال الرمز، حاول مجدداً';
  }

  Map<String, dynamic>? _coerceResponseMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  Future<Result<bool>> resendWhatsAppOtp(
    String phoneE164, {
    String? purpose,
  }) =>
      sendWhatsAppOtp(phoneE164, purpose: purpose);

  Future<Result<AuthResult>> verifyWhatsAppOtp({
    required String phone,
    required String otp,
    String? purpose,
  }) async {
    try {
      final e164 = Validators.normalizeE164(phone);
      if (kDebugMode) {
        debugPrint('verifyWhatsAppOtp → $e164 purpose=$purpose');
      }
      final response = await _client.functions.invoke(
        'verify-whatsapp-otp',
        body: {
          'phone': e164,
          'code': otp.trim(),
          if (purpose != null) 'purpose': purpose,
        },
      );

      final data = response.data;
      if (response.status != 200 ||
          data is! Map ||
          data['status'] != 'approved') {
        return const Failure('رمز غير صحيح');
      }

      final tokenHash = data['token_hash'] as String?;
      if (tokenHash == null || tokenHash.isEmpty) {
        return const Failure('تعذّر إنشاء الجلسة. حاول مرة أخرى.');
      }

      final verifyResponse = await _client.auth.verifyOTP(
        tokenHash: tokenHash,
        type: OtpType.magiclink,
      );

      Session? session = verifyResponse.session;
      for (var i = 0; i < 3; i++) {
        session ??= _client.auth.currentSession;
        if (session != null) break;
        await Future.delayed(const Duration(milliseconds: 500));
      }

      if (session == null) {
        if (kDebugMode) {
          debugPrint('verifyWhatsAppOtp: session not established after retries');
        }
        return const Failure('تعذّر إنشاء الجلسة. حاول مرة أخرى.');
      }

      final user = session.user;
      if (kDebugMode) {
        debugPrint('verifyWhatsAppOtp: session established for ${user.id}');
      }

      final profile = await _fetchProfile(user.id);
      final isNewUser = profile == null || !profile.isComplete;

      return Success(
        AuthResult(user: user, isNewUser: isNewUser),
      );
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('رمز غير صحيح', cause: e);
    }
  }

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

  Future<Result<bool>> signInWithPassword({
    required String email,
    required String password,
  }) async {
    try {
      if (kDebugMode) {
        debugPrint('signInWithPassword → $email');
      }
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.session == null) {
        return const Failure('تعذّر تسجيل الدخول. تحقق من البريد وكلمة المرور.');
      }

      if (kDebugMode) {
        debugPrint('signInWithPassword ← session for ${response.user?.id}');
      }
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر تسجيل الدخول. حاول مرة أخرى.', cause: e);
    }
  }

  Future<Result<bool>> signUpWithPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    try {
      final fullName = '$firstName $lastName'.trim();
      if (kDebugMode) {
        debugPrint(
          'signUpWithPassword → email=$email '
          'firstName=$firstName lastName=$lastName fullName=$fullName '
          'username=$username',
        );
      }
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': fullName,
        },
      );

      if (response.session == null) {
        return const Failure('تعذّر إنشاء الحساب. حاول مرة أخرى.');
      }

      final userId = response.user!.id;
      final profileResult = await _upsertSignupProfile(
        userId: userId,
        email: email.trim(),
        fullName: fullName,
        username: username,
      );
      if (profileResult case Failure(:final message)) {
        return Failure(message);
      }

      if (kDebugMode) {
        debugPrint('signUpWithPassword ← session for $userId');
      }
      return const Success(true);
    } on AuthException catch (e, st) {
      logAuthError(e, st);
      return Failure(authErrorMessage(e), cause: e);
    } catch (e, st) {
      logAuthError(e, st);
      return Failure(authErrorMessage(e), cause: e);
    }
  }

  Future<Result<bool>> resetPasswordForEmail(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: AppConstants.authRedirectUri,
      );
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر إرسال رابط إعادة التعيين.', cause: e);
    }
  }

  Future<Result<bool>> isEmailRegistered(String email) async {
    try {
      final registered = await _client.rpc(
        'check_registered_email',
        params: {'p_email': email.trim()},
      );
      return Success(registered == true);
    } catch (e) {
      return Failure('تعذّر التحقق من البريد.', cause: e);
    }
  }

  Future<Result<bool>> isPhoneRegistered(String phoneE164) async {
    try {
      final phone = Validators.normalizeE164(phoneE164);
      final registered = await _client.rpc(
        'check_registered_phone',
        params: {'p_phone': phone},
      );
      return Success(registered == true);
    } catch (e) {
      return Failure('تعذّر التحقق من رقم الهاتف.', cause: e);
    }
  }

  Future<Result<bool>> resendPhoneOtp(String phoneE164) async {
    try {
      await _client.auth.resend(
        type: OtpType.sms,
        phone: Validators.normalizeE164(phoneE164),
      );
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر إعادة إرسال الرمز.', cause: e);
    }
  }

  Future<Result<bool>> resendEmailOtp(String email) async {
    try {
      await _client.auth.resend(
        type: OtpType.email,
        email: email.trim(),
      );
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر إعادة إرسال الرمز.', cause: e);
    }
  }

  Future<Result<AuthResult>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _client.auth.verifyOTP(
        email: email.trim(),
        token: otp.trim(),
        type: OtpType.email,
      );

      Session? session = response.session ?? _client.auth.currentSession;
      if (session == null) {
        return const Failure('رمز غير صحيح');
      }

      final user = session.user;
      final profile = await _fetchProfile(user.id);
      final isNewUser = profile == null || !profile.isComplete;

      return Success(AuthResult(user: user, isNewUser: isNewUser));
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('رمز غير صحيح', cause: e);
    }
  }

  Future<Result<bool>> updatePassword(String password) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: password));
      return const Success(true);
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر تحديث كلمة المرور.', cause: e);
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

  Future<Result<bool>> signInWithApple() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
        if (kDebugMode) {
          debugPrint('signInWithApple → native iOS');
        }
        final response = await signInWithAppleNative(_client.auth);
        if (response.session == null) {
          return const Failure('تعذّر تسجيل الدخول بـ Apple. حاول مرة أخرى.');
        }
        if (kDebugMode) {
          debugPrint(
            'signInWithApple ← native session for ${response.user?.id}',
          );
        }
        return const Success(true);
      }

      if (kDebugMode) {
        debugPrint('signInWithApple → launching OAuth');
      }
      await _client.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: AppConstants.authRedirectUri,
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      return const Success(true);
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) {
        return const Failure('تم إلغاء تسجيل الدخول.');
      }
      return Failure(
        'تعذّر تسجيل الدخول بـ Apple. حاول مرة أخرى.',
        cause: e,
      );
    } on AuthException catch (e) {
      return Failure(authErrorMessage(e), cause: e);
    } catch (e) {
      return Failure('تعذّر تسجيل الدخول بـ Apple. حاول مرة أخرى.', cause: e);
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

  Future<Result<bool>> _upsertSignupProfile({
    required String userId,
    required String email,
    required String fullName,
    String? username,
  }) async {
    try {
      final createdAt = DateTime.now().toUtc().toIso8601String();
      await _client.from('profiles').upsert({
        'id': userId,
        'email': email,
        'full_name': fullName,
        'display_name': fullName,
        if (username != null && username.isNotEmpty)
          'username': normalizeUsername(username),
        'created_at': createdAt,
      });
      if (kDebugMode) {
        debugPrint('_upsertSignupProfile ← profile for $userId');
      }
      return const Success(true);
    } on PostgrestException catch (e) {
      if (kDebugMode) {
        debugPrint('_upsertSignupProfile failed: ${e.message}');
      }
      return Failure('تعذّر حفظ الملف الشخصي.', cause: e);
    } catch (e) {
      return Failure('تعذّر حفظ الملف الشخصي.', cause: e);
    }
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
