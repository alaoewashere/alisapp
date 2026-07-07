import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/result.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../profile/data/profile_repository.dart';
import '../data/auth_repository.dart';
import '../domain/auth_result.dart';

export '../data/auth_repository.dart';
export '../domain/auth_result.dart';

enum AuthFlowStatus {
  initial,
  loading,
  otpSent,
  authenticated,
  error,
}

enum OAuthLoading {
  google,
  apple,
  facebook,
}

class AuthFlowState {
  const AuthFlowState({
    this.status = AuthFlowStatus.initial,
    this.errorMessage,
    this.phone,
    this.lastAuthResult,
    this.isGuest = false,
    this.oauthLoading,
  });

  final AuthFlowStatus status;
  final String? errorMessage;
  final String? phone;
  final AuthResult? lastAuthResult;
  final bool isGuest;
  final OAuthLoading? oauthLoading;

  AuthFlowState copyWith({
    AuthFlowStatus? status,
    String? errorMessage,
    String? phone,
    AuthResult? lastAuthResult,
    bool? isGuest,
    OAuthLoading? oauthLoading,
    bool clearError = false,
    bool clearPhone = false,
    bool clearOAuthLoading = false,
  }) {
    return AuthFlowState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phone: clearPhone ? null : (phone ?? this.phone),
      lastAuthResult: lastAuthResult ?? this.lastAuthResult,
      isGuest: isGuest ?? this.isGuest,
      oauthLoading:
          clearOAuthLoading ? null : (oauthLoading ?? this.oauthLoading),
    );
  }
}

class AuthNotifier extends Notifier<AuthFlowState> {
  @override
  AuthFlowState build() {
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState.session != null) {
          if (state.isGuest) {
            state = state.copyWith(isGuest: false);
          }
          if (state.status == AuthFlowStatus.loading && state.phone == null) {
            state = state.copyWith(
              status: AuthFlowStatus.authenticated,
              isGuest: false,
              clearError: true,
            );
          }
        }
      });
    });
    return const AuthFlowState();
  }

  void enterGuestMode() {
    state = state.copyWith(
      isGuest: true,
      status: AuthFlowStatus.initial,
      clearError: true,
    );
  }

  void exitGuestMode() {
    state = state.copyWith(isGuest: false);
  }

  Future<Result<bool>> sendOTP(String phoneNumber) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      phone: phoneNumber,
    );

    final result = await ref.read(authRepositoryProvider).sendOTP(phoneNumber);

    switch (result) {
      case Success():
        state = state.copyWith(
          status: AuthFlowStatus.otpSent,
          phone: phoneNumber,
          clearError: true,
        );
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<AuthResult>> verifyOTP({
    required String phone,
    required String otp,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
    );

    final result = await ref.read(authRepositoryProvider).verifyOTP(
          phone: phone,
          otp: otp,
        );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          lastAuthResult: value,
          clearError: true,
        );
        ref.invalidate(currentProfileProvider);
        return Success(value);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<AuthResult>> verifyWhatsAppOtp({
    required String phone,
    required String otp,
    String? purpose,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      phone: phone,
    );

    final result = await ref.read(authRepositoryProvider).verifyWhatsAppOtp(
          phone: phone,
          otp: otp,
          purpose: purpose,
        );

    switch (result) {
      case Success(:final value):
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          lastAuthResult: value,
          clearError: true,
        );
        ref.invalidate(currentProfileProvider);
        return Success(value);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      clearPhone: true,
    );

    final result = await ref.read(authRepositoryProvider).signInWithPassword(
          email: email,
          password: password,
        );

    switch (result) {
      case Success():
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          clearError: true,
        );
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? username,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      clearPhone: true,
    );

    final result = await ref.read(authRepositoryProvider).signUpWithPassword(
          email: email,
          password: password,
          firstName: firstName,
          lastName: lastName,
          username: username,
        );

    switch (result) {
      case Success(value: false):
        // Email confirmation required — not yet authenticated.
        state = state.copyWith(status: AuthFlowStatus.initial, clearError: true);
        return const Success(false);
      case Success():
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          clearError: true,
        );
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> resetPasswordForEmail(String email) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      clearError: true,
      clearPhone: true,
    );
    final result =
        await ref.read(authRepositoryProvider).resetPasswordForEmail(email);
    switch (result) {
      case Success():
        state = state.copyWith(status: AuthFlowStatus.initial, clearError: true);
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<AuthResult>> verifyEmailOTP({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      clearPhone: true,
    );
    final result = await ref.read(authRepositoryProvider).verifyEmailOTP(
          email: email,
          otp: otp,
        );
    switch (result) {
      case Success(:final value):
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          lastAuthResult: value,
          clearError: true,
        );
        return Success(value);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> updatePassword(String password) async {
    state = state.copyWith(status: AuthFlowStatus.loading, clearError: true);
    final result =
        await ref.read(authRepositoryProvider).updatePassword(password);
    switch (result) {
      case Success():
        state = state.copyWith(status: AuthFlowStatus.initial, clearError: true);
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> signInWithGoogle() async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      oauthLoading: OAuthLoading.google,
    );

    final result = await ref.read(authRepositoryProvider).signInWithGoogle();

    switch (result) {
      case Success():
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
          clearOAuthLoading: true,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> signInWithFacebook() async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      oauthLoading: OAuthLoading.facebook,
    );

    final result = await ref.read(authRepositoryProvider).signInWithFacebook();

    switch (result) {
      case Success():
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
          clearOAuthLoading: true,
        );
        return Failure(message);
    }
  }

  Future<Result<bool>> signInWithApple() async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
      oauthLoading: OAuthLoading.apple,
    );

    final result = await ref.read(authRepositoryProvider).signInWithApple();

    switch (result) {
      case Success():
        ref.invalidate(currentProfileProvider);
        state = state.copyWith(
          status: AuthFlowStatus.authenticated,
          isGuest: false,
          clearError: true,
          clearOAuthLoading: true,
        );
        return const Success(true);
      case Failure(:final message):
        if (message == 'تم إلغاء تسجيل الدخول.') {
          state = state.copyWith(
            status: AuthFlowStatus.initial,
            clearOAuthLoading: true,
            clearError: true,
          );
          return Failure(message);
        }
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
          clearOAuthLoading: true,
        );
        return Failure(message);
    }
  }

  void onOAuthSessionEstablished() {
    state = state.copyWith(
      status: AuthFlowStatus.authenticated,
      isGuest: false,
      clearError: true,
      clearOAuthLoading: true,
    );
  }

  void onOAuthFailed(String message) {
    state = state.copyWith(
      status: AuthFlowStatus.error,
      errorMessage: message,
      clearOAuthLoading: true,
    );
  }

  void clearOAuthLoading() {
    if (state.status == AuthFlowStatus.loading || state.oauthLoading != null) {
      state = state.copyWith(
        status: AuthFlowStatus.initial,
        clearOAuthLoading: true,
      );
    }
  }

  Future<Result<bool>> signOut() async {
    state = state.copyWith(status: AuthFlowStatus.loading, clearError: true);
    final result = await ref.read(authRepositoryProvider).signOut();

    switch (result) {
      case Success():
        state = const AuthFlowState();
        ref.invalidate(currentProfileProvider);
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  void clearError() {
    if (state.status == AuthFlowStatus.error) {
      state = state.copyWith(clearError: true, status: AuthFlowStatus.initial);
    }
  }

  /// Leaves the OTP step so the user can change their phone number.
  void cancelOtpFlow() {
    state = state.copyWith(
      status: AuthFlowStatus.initial,
      clearPhone: true,
      clearError: true,
    );
  }
}

final authNotifierProvider =
    NotifierProvider<AuthNotifier, AuthFlowState>(AuthNotifier.new);

final isGuestProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isGuest;
});

final isGoogleSignInLoadingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.status == AuthFlowStatus.loading &&
      auth.oauthLoading == OAuthLoading.google;
});

final isAppleSignInLoadingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.status == AuthFlowStatus.loading &&
      auth.oauthLoading == OAuthLoading.apple;
});

final isFacebookSignInLoadingProvider = Provider<bool>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth.status == AuthFlowStatus.loading &&
      auth.oauthLoading == OAuthLoading.facebook;
});
