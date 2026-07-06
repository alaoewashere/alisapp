import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/category_locale.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/constants/app_governorates.dart';
import '../../../core/constants/dicebear_avatars.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/sello_app_bar.dart';
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

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    // Prefill the name from the account when available (Sign in with Apple only
    // returns it on first authorization), otherwise the user types it.
    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentUser;
    final prefill = user != null
        ? fullNameFromAuthUser(user, pendingSignup: ref.read(pendingSignupProvider))
        : '';
    _nameController = TextEditingController(text: prefill);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final setup = ref.watch(_profileSetupProvider);
    final governorate = ref.watch(_setupGovernorateProvider);
    final strings = ref.watch(appLocalizationsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SelloAppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(strings.completeProfileTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: setup.submitting
                  ? null
                  : () => _showAvatarPicker(context),
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
            strings.tapToChooseAvatar,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            enabled: !setup.submitting,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.words,
            style: AppFonts.cairo(fontSize: 15, color: AppColors.textDark),
            decoration: InputDecoration(labelText: strings.fullName),
            onChanged: (_) {
              if (setup.errorMessage != null) {
                ref.read(_profileSetupProvider.notifier).clearError();
              }
            },
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: governorate,
            decoration: InputDecoration(labelText: strings.governorate),
            items: iraqiGovernorates
                .map(
                  (g) => DropdownMenuItem(
                    value: g.slug,
                    child: Text(g.displayName(ref.watch(categoryLocaleCodeProvider))),
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
            label: strings.startNow,
            loading: setup.submitting,
            onPressed: setup.submitting
                ? null
                : () => _submit(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showAvatarPicker(BuildContext context) async {
    final setup = ref.read(_profileSetupProvider);
    await showAvatarPickerSheet(
      context,
      currentSeed: setup.selectedAvatarSeed,
      onSelected: (seed) {
        ref.read(_profileSetupProvider.notifier).selectAvatarSeed(seed);
      },
    );
  }

  Future<void> _submit(BuildContext context) async {
    final governorate = ref.read(_setupGovernorateProvider);
    if (governorate == null) {
      ref.read(_profileSetupProvider.notifier).setError(
            ref.read(appLocalizationsProvider).selectGovernorate,
          );
      return;
    }

    final client = ref.read(supabaseClientProvider);
    final user = client.auth.currentSession?.user ?? client.auth.currentUser;
    if (user == null) {
      _handleSessionExpired(context);
      return;
    }

    // Use the typed name. Sign in with Apple often returns no name (re-auth or
    // hidden), so we never hard-block — the user just fills it in here.
    final fullName = _nameController.text.trim();
    if (fullName.isEmpty) {
      ref.read(_profileSetupProvider.notifier).setError(
            ref.read(appLocalizationsProvider).enterName,
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
          _handleSessionExpired(context);
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

  void _handleSessionExpired(BuildContext context) {
    ref.read(_profileSetupProvider.notifier).setSubmitting(false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ref.read(appLocalizationsProvider).sessionExpiredPleaseLogin),
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

  void clearError() => state = state.copyWith(clearError: true);
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
