import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/constants/dicebear_avatars.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/dicebear_avatar_cell.dart';
import '../../../widgets/avatar_picker_sheet.dart';
import '../data/auth_repository.dart';
import '../providers/pending_signup_provider.dart';
import '../../profile/data/profile_repository.dart';

/// Resolves display name from auth metadata (set during signup).
String fullNameFromAuthUser(User user, {PendingSignupData? pendingSignup}) {
  final meta = user.userMetadata;
  final fromMeta = (meta?['full_name'] as String?)?.trim() ??
      (meta?['name'] as String?)?.trim() ??
      '';
  if (fromMeta.isNotEmpty) return fromMeta;
  return pendingSignup?.fullName.trim() ?? '';
}

class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(_profileSetupProvider);
    final governorate = ref.watch(_setupGovernorateProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: const Text('أكمل ملفك الشخصي'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: setup.submitting
                  ? null
                  : () => _showAvatarPicker(context, ref),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DiceBearAvatarPreview(
                    seed: setup.selectedAvatarSeed,
                    size: 90,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'اضغط لاختيار صورتك الرمزية',
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          DropdownButtonFormField<String>(
            initialValue: governorate,
            decoration: const InputDecoration(labelText: 'المحافظة'),
            items: iraqiGovernorates
                .map(
                  (g) => DropdownMenuItem(
                    value: g.slug,
                    child: Text(g.nameAr),
                  ),
                )
                .toList(),
            onChanged: setup.submitting
                ? null
                : (v) => ref.read(_setupGovernorateProvider.notifier).set(v),
          ),
          if (setup.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              setup.errorMessage!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          const SizedBox(height: 32),
          CustomButton(
            label: 'ابدأ الآن',
            loading: setup.submitting,
            onPressed: setup.submitting
                ? null
                : () => _submit(context, ref),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarPicker(BuildContext context, WidgetRef ref) async {
    final setup = ref.read(_profileSetupProvider);
    await showAvatarPickerSheet(
      context,
      currentSeed: setup.selectedAvatarSeed,
      onSelected: (seed) {
        ref.read(_profileSetupProvider.notifier).selectAvatarSeed(seed);
      },
    );
  }

  Future<void> _submit(BuildContext context, WidgetRef ref) async {
    final governorate = ref.read(_setupGovernorateProvider);
    if (governorate == null) {
      ref.read(_profileSetupProvider.notifier).setError('اختر المحافظة');
      return;
    }

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentSession?.user ?? client.auth.currentUser;
    if (user == null) {
      _handleSessionExpired(context, ref);
      return;
    }

    final fullName = fullNameFromAuthUser(
      user,
      pendingSignup: ref.read(pendingSignupProvider),
    );
    if (fullName.isEmpty) {
      ref.read(_profileSetupProvider.notifier).setError(
            'تعذّر قراءة الاسم من الحساب. سجّل الدخول مجدداً.',
          );
      return;
    }

    ref.read(_profileSetupProvider.notifier).setSubmitting(true);

    final setup = ref.read(_profileSetupProvider);
    final authRepo = ref.read(authRepositoryProvider);
    final avatarSeed = DiceBearAvatars.resolveSeed(setup.selectedAvatarSeed);

    final profile = ProfileModel(
      id: user.id,
      fullName: fullName,
      phone: user.phone,
      avatarSeed: avatarSeed,
      governorate: governorate,
      createdAt: DateTime.now(),
    );

    final result = await authRepo.createProfile(profile);

    if (!context.mounted) return;

    switch (result) {
      case Success():
        ref.read(pendingSignupProvider.notifier).clear();
        ref.invalidate(currentProfileProvider);
        ref.read(_profileSetupProvider.notifier).setSubmitting(false);
        context.go(AppRoutes.home);
      case Failure(:final message):
        ref.read(_profileSetupProvider.notifier).setSubmitting(false);
        if (_isAuthFailure(message)) {
          _handleSessionExpired(context, ref);
        } else {
          ref.read(_profileSetupProvider.notifier).setError(message);
        }
    }
  }

  bool _isAuthFailure(String message) {
    final lower = message.toLowerCase();
    return message.contains('يجب تسجيل الدخول') ||
        lower.contains('jwt') ||
        lower.contains('session') ||
        lower.contains('not authenticated');
  }

  void _handleSessionExpired(BuildContext context, WidgetRef ref) {
    ref.read(_profileSetupProvider.notifier).setSubmitting(false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('انتهت جلستك، يرجى تسجيل الدخول مجدداً'),
      ),
    );
    context.go(AppRoutes.login);
  }
}

class ProfileSetupState {
  const ProfileSetupState({
    this.selectedAvatarSeed,
    this.submitting = false,
    this.errorMessage,
  });

  final String? selectedAvatarSeed;
  final bool submitting;
  final String? errorMessage;

  ProfileSetupState copyWith({
    String? selectedAvatarSeed,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileSetupState(
      selectedAvatarSeed: selectedAvatarSeed ?? this.selectedAvatarSeed,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState(
        selectedAvatarSeed: DiceBearAvatars.defaultSeed,
      );

  void selectAvatarSeed(String seed) => state = state.copyWith(
        selectedAvatarSeed: seed,
        clearError: true,
      );

  void setSubmitting(bool value) => state = state.copyWith(submitting: value);

  void setError(String message) =>
      state = state.copyWith(errorMessage: message, submitting: false);
}

final _profileSetupProvider =
    NotifierProvider<ProfileSetupNotifier, ProfileSetupState>(
  ProfileSetupNotifier.new,
);

class _SetupGovernorateNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final _setupGovernorateProvider =
    NotifierProvider<_SetupGovernorateNotifier, String?>(
  _SetupGovernorateNotifier.new,
);
