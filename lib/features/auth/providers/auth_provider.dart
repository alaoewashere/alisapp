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

class AuthFlowState {
  const AuthFlowState({
    this.status = AuthFlowStatus.initial,
    this.errorMessage,
    this.phone,
    this.lastAuthResult,
    this.isGuest = false,
  });

  final AuthFlowStatus status;
  final String? errorMessage;
  final String? phone;
  final AuthResult? lastAuthResult;
  final bool isGuest;

  AuthFlowState copyWith({
    AuthFlowStatus? status,
    String? errorMessage,
    String? phone,
    AuthResult? lastAuthResult,
    bool? isGuest,
    bool clearError = false,
    bool clearPhone = false,
  }) {
    return AuthFlowState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      phone: clearPhone ? null : (phone ?? this.phone),
      lastAuthResult: lastAuthResult ?? this.lastAuthResult,
      isGuest: isGuest ?? this.isGuest,
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

  Future<Result<bool>> signInWithGoogle() async {
    state = state.copyWith(
      status: AuthFlowStatus.loading,
      isGuest: false,
      clearError: true,
    );

    final result = await ref.read(authRepositoryProvider).signInWithGoogle();

    switch (result) {
      case Success():
        return const Success(true);
      case Failure(:final message):
        state = state.copyWith(
          status: AuthFlowStatus.error,
          errorMessage: message,
        );
        return Failure(message);
    }
  }

  void onOAuthSessionEstablished() {
    state = state.copyWith(
      status: AuthFlowStatus.authenticated,
      isGuest: false,
      clearError: true,
    );
  }

  void onOAuthFailed(String message) {
    state = state.copyWith(
      status: AuthFlowStatus.error,
      errorMessage: message,
    );
  }

  void clearOAuthLoading() {
    if (state.status == AuthFlowStatus.loading) {
      state = state.copyWith(status: AuthFlowStatus.initial);
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
      auth.phone == null &&
      !auth.isGuest;
});
