import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../theme/app_form_fields.dart';
import '../../theme/app_text_styles.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/moderation/moderation_provider.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../shared/models/profile_model.dart';
import '../../widgets/avatar_picker_sheet.dart';
import '../../widgets/user_avatar.dart';
import 'widgets/edit_profile_phone_sheet.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _groupSpacing = 16.0;
  static const _labelGap = 6.0;
  static const _hintGap = 4.0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  var _loading = true;
  var _isSaving = false;
  String _avatarSeed = DiceBearAvatars.defaultSeed;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      if (userId == null) {
        if (mounted) context.pop();
        return;
      }

      final profile = await ref
          .read(profileRepositoryProvider)
          .getProfile(userId);
      if (!mounted) return;

      if (profile == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(appLocalizationsProvider).profileNotFound)),
        );
        return;
      }

      final authEmail = supabase.auth.currentUser?.email?.trim();
      final email = (profile.email?.trim().isNotEmpty == true)
          ? profile.email!.trim()
          : (authEmail?.isNotEmpty == true ? authEmail! : '');

      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _emailController.text = email;
        _avatarSeed = profile.effectiveAvatarSeed;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.read(appLocalizationsProvider).profileLoadFailed)),
        );
      }
    }
  }

  Future<void> _openPhoneEditor() async {
    final profile = _profile;
    if (profile == null || _isSaving) return;

    final phoneE164 = await showEditProfilePhoneSheet(
      context,
      ref,
      initialPhoneE164: profile.phone,
    );

    if (!mounted || phoneE164 == null || phoneE164.isEmpty) return;

    await _loadProfile();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ref.read(appLocalizationsProvider).changesSavedSuccess,
          style: AppFonts.cairo(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _showAvatarPicker() async {
    await showAvatarPickerSheet(
      context,
      currentSeed: _avatarSeed,
      onSelected: (seed) async {
        setState(() => _avatarSeed = seed);
        final userId = ref.read(currentUserIdProvider);
        if (userId == null) return;
        final result = await ref
            .read(profileNotifierProvider.notifier)
            .updateAvatarSeed(seed);
        if (!mounted) return;
        switch (result) {
          case Success(:final value):
            setState(() => _avatarSeed = value.effectiveAvatarSeed);
          case Failure(:final message):
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
        }
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = _profile;
    if (profile == null) return;

    setState(() => _isSaving = true);

    try {
      final name = _nameController.text.trim();

      if (await checkPostingBanGate(ref, context)) {
        setState(() => _isSaving = false);
        return;
      }

      final moderation = await moderateUserText(ref, text: name);
      if (!mounted) return;

      if (moderation.shouldBlock) {
        setState(() => _isSaving = false);
        PostingBanInfo? banInfo;
        try {
          banInfo = await recordClientModerationBlock(
            ref.read(moderationRepositoryProvider),
            source: 'profile',
            fieldName: 'full_name',
            excerpt: name,
          );
          ref.invalidateModerationState();
        } catch (e) {
          await handlePostingBanOrBlockError(ref, context, e);
          return;
        }
        if (!mounted) return;
        await showModerationBlockedWarning(context, banInfo: banInfo);
        return;
      }

      if (moderation.hadViolation) {
        await showModerationCensoredWarning(context);
      }

      final updated = profile.copyWith(
        fullName: name,
        avatarSeed: _avatarSeed,
      );

      final result = await ref
          .read(profileNotifierProvider.notifier)
          .updateProfile(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                ref.read(appLocalizationsProvider).changesSavedSuccess,
                style: AppFonts.cairo(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        case Failure(:final message, :final cause):
          final err = cause ?? message;
          if (isUserPostingBannedError(err) || isModerationBlockedError(err)) {
            await handlePostingBanOrBlockError(ref, context, err);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(ref.read(appLocalizationsProvider).saveError)),
            );
          }
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ref.read(appLocalizationsProvider).saveError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final profile = _profile;
    final emailDisplay = _emailController.text.trim();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: AppBackButton(
            onPressed: _isSaving ? null : () => context.pop(),
          ),
          title: Text(
            strings.editProfile,
            style: AppTextStyles.subheading.copyWith(fontSize: 18),
          ),
          actions: [
            TextButton(
              onPressed: _isSaving || _loading ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      strings.save,
                      style: AppFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AvatarSection(
                        avatarSeed: _avatarSeed,
                        changePhotoLabel: strings.changePhoto,
                        onTap: _isSaving ? null : _showAvatarPicker,
                      ),
                      const SizedBox(height: 20),
                      _EditField(
                        label: strings.fullName,
                        labelGap: _labelGap,
                        spacing: _groupSpacing,
                        child: TextFormField(
                          controller: _nameController,
                          style: AppTextStyles.input,
                          textInputAction: TextInputAction.next,
                          validator: (v) => v == null || v.trim().isEmpty
                              ? strings.enterName
                              : null,
                          decoration: AppFormDecorations.underline(
                            hintText: strings.fullName,
                          ),
                        ),
                      ),
                      if (profile != null)
                        _EditField(
                          label: strings.usernameLabel,
                          labelGap: _labelGap,
                          spacing: _groupSpacing,
                          hintGap: _hintGap,
                          hint: Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                strings.usernameCannotChange,
                                style: AppFonts.cairo(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          child: _ReadOnlyFieldBox(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  profile.hasUsername
                                      ? '@${profile.username}'
                                      : '—',
                                  style: AppTextStyles.input.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      _EditField(
                        label: strings.emailLabel,
                        labelGap: _labelGap,
                        spacing: _groupSpacing,
                        child: _ReadOnlyFieldBox(
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                emailDisplay.isNotEmpty
                                    ? emailDisplay
                                    : 'example@email.com',
                                style: AppTextStyles.input.copyWith(
                                  color: emailDisplay.isNotEmpty
                                      ? AppColors.textMuted
                                      : AppColors.textMuted
                                          .withValues(alpha: 0.55),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (profile != null)
                        _EditField(
                          label: strings.phoneNumber,
                          labelGap: _labelGap,
                          spacing: _groupSpacing,
                          hintGap: _hintGap,
                          hint: GestureDetector(
                            onTap: _isSaving ? null : _openPhoneEditor,
                            child: Text(
                              strings.changePhoneNumber,
                              style: AppFonts.cairo(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          child: _ReadOnlyFieldBox(
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  profile.hasDisplayPhone
                                      ? Validators.normalizeE164(profile.phone!)
                                      : '—',
                                  style: AppTextStyles.input.copyWith(
                                    color: profile.hasDisplayPhone
                                        ? AppColors.textDark
                                        : AppColors.textMuted
                                            .withValues(alpha: 0.55),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _ReadOnlyFieldBox extends StatelessWidget {
  const _ReadOnlyFieldBox({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }
}

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.avatarSeed,
    required this.changePhotoLabel,
    required this.onTap,
  });

  final String avatarSeed;
  final String changePhotoLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              UserAvatar(avatarSeed: avatarSeed, size: 90),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.fieldCarbon,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.fieldCarbon, width: 2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.face_retouching_natural,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Text(
            changePhotoLabel,
            style: AppFonts.cairo(
              fontSize: 13,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _EditField extends StatelessWidget {
  const _EditField({
    required this.label,
    required this.child,
    this.hint,
    this.labelGap = 6,
    this.hintGap = 4,
    this.spacing = 16,
  });

  final String label;
  final Widget child;
  final Widget? hint;
  final double labelGap;
  final double hintGap;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: spacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: labelGap),
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                Text(label, style: AppTextStyles.subheading),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          child,
          if (hint != null) ...[
            SizedBox(height: hintGap),
            hint!,
          ],
        ],
      ),
    );
  }
}
