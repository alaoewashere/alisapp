import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/router/app_router.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../data/auth_repository.dart';
import '../../profile/data/profile_repository.dart';

class ProfileSetupScreen extends ConsumerWidget {
  const ProfileSetupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(_profileSetupProvider);
    final nameController = ref.watch(_fullNameControllerProvider);
    final governorate = ref.watch(_setupGovernorateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('أكمل ملفك الشخصي')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                'أكمل ملفك الشخصي',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              Center(
                child: GestureDetector(
                  onTap: setup.submitting
                      ? null
                      : () => _pickAvatar(context, ref),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor:
                            Theme.of(context).colorScheme.surfaceContainerHighest,
                        backgroundImage: setup.avatarFile != null
                            ? FileImage(setup.avatarFile!)
                            : null,
                        child: setup.avatarFile == null
                            ? const Icon(Icons.person, size: 48)
                            : null,
                      ),
                      const CircleAvatar(
                        radius: 16,
                        child: Icon(Icons.camera_alt, size: 16),
                      ),
                    ],
                  ),
                ),
              ),
              if (setup.uploadProgress > 0 && setup.uploadProgress < 1) ...[
                const SizedBox(height: 12),
                LinearProgressIndicator(value: setup.uploadProgress),
                const SizedBox(height: 4),
                Text(
                  'جاري رفع الصورة... ${(setup.uploadProgress * 100).round()}%',
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              CustomTextField(
                controller: nameController,
                label: 'الاسم الكامل',
                validator: (v) => Validators.requiredField(v, label: 'الاسم'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: governorate,
                decoration: const InputDecoration(labelText: 'المحافظة'),
                items: iraqiGovernorates
                    .map((g) => DropdownMenuItem(value: g.slug, child: Text(g.nameAr)))
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
                    : () => _submit(context, ref, nameController.text.trim()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('الكاميرا'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ref.read(_imagePickerProvider);
    final image = await picker.pickImage(source: source, imageQuality: 85);
    if (image == null) return;

    ref.read(_profileSetupProvider.notifier).setAvatar(File(image.path));
  }

  Future<void> _submit(
    BuildContext context,
    WidgetRef ref,
    String fullName,
  ) async {
    final governorate = ref.read(_setupGovernorateProvider);
    if (fullName.isEmpty) {
      ref.read(_profileSetupProvider.notifier).setError('الاسم الكامل مطلوب');
      return;
    }
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
    final userId = user.id;

    ref.read(_profileSetupProvider.notifier).setSubmitting(true);

    String? avatarUrl;
    final avatarFile = ref.read(_profileSetupProvider).avatarFile;
    final authRepo = ref.read(authRepositoryProvider);

    if (avatarFile != null) {
      ref.read(_profileSetupProvider.notifier).setUploadProgress(0.2);
      final bytes = await avatarFile.readAsBytes();
      final ext = avatarFile.path.split('.').last.toLowerCase();
      final uploadResult = await authRepo.uploadAvatar(
        userId: userId,
        bytes: bytes,
        fileExtension: ext,
        onProgress: (p) =>
            ref.read(_profileSetupProvider.notifier).setUploadProgress(p),
      );

      switch (uploadResult) {
        case Success(:final value):
          avatarUrl = value;
        case Failure(:final message):
          ref.read(_profileSetupProvider.notifier).setSubmitting(false);
          ref.read(_profileSetupProvider.notifier).setError(message);
          return;
      }
    }

    final phone = user.phone;
    final profile = ProfileModel(
      id: userId,
      fullName: fullName,
      phone: phone,
      avatarUrl: avatarUrl,
      governorate: governorate,
      createdAt: DateTime.now(),
    );

    final result = await authRepo.createProfile(profile);

    if (!context.mounted) return;

    switch (result) {
      case Success():
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
    context.go(AppRoutes.phone);
  }
}

class ProfileSetupState {
  const ProfileSetupState({
    this.avatarFile,
    this.uploadProgress = 0,
    this.submitting = false,
    this.errorMessage,
  });

  final File? avatarFile;
  final double uploadProgress;
  final bool submitting;
  final String? errorMessage;

  ProfileSetupState copyWith({
    File? avatarFile,
    double? uploadProgress,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileSetupState(
      avatarFile: avatarFile ?? this.avatarFile,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ProfileSetupNotifier extends Notifier<ProfileSetupState> {
  @override
  ProfileSetupState build() => const ProfileSetupState();

  void setAvatar(File file) =>
      state = state.copyWith(avatarFile: file, clearError: true);

  void setUploadProgress(double value) =>
      state = state.copyWith(uploadProgress: value);

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

final _fullNameControllerProvider = Provider.autoDispose((ref) {
  final c = TextEditingController();
  ref.onDispose(c.dispose);
  return c;
});

final _imagePickerProvider = Provider((ref) => ImagePicker());
