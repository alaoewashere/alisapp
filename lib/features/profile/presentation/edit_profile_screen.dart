import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_governorates.dart';
import '../../../core/utils/result.dart';
import '../../../core/utils/validators.dart';
import '../../../shared/models/profile_model.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _cityController;
  String? _governorate;
  File? _newAvatar;
  var _saving = false;
  var _uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _cityController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _initFromProfile(ProfileModel profile) {
    if (_nameController.text.isEmpty) {
      _nameController.text = profile.fullName;
      _cityController.text = profile.city ?? '';
      _governorate = profile.governorate;
    }
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (file != null) {
      setState(() => _newAvatar = File(file.path));
    }
  }

  Future<void> _showAvatarSheet(ProfileModel profile) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: const Text('الكاميرا'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('المعرض'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (profile.avatarUrl != null || _newAvatar != null)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: const Text('إزالة الصورة'),
                onTap: () async {
                  Navigator.pop(ctx);
                  await ref.read(profileNotifierProvider.notifier).removeAvatar();
                  setState(() => _newAvatar = null);
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(ProfileModel current) async {
    if (!_formKey.currentState!.validate()) return;
    if (_governorate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('اختر المحافظة')),
      );
      return;
    }

    setState(() {
      _saving = true;
      _uploadProgress = 0;
    });

    try {
      if (_newAvatar != null) {
        setState(() => _uploadProgress = 0.3);
        final avatarResult =
            await ref.read(profileNotifierProvider.notifier).updateAvatar(
                  _newAvatar!,
                );
        switch (avatarResult) {
          case Failure(:final message):
            throw Exception(message);
          case Success():
            break;
        }
        setState(() => _uploadProgress = 0.7);
      }

      final updated = current.copyWith(
        fullName: _nameController.text.trim(),
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        governorate: _governorate,
      );

      final result =
          await ref.read(profileNotifierProvider.notifier).updateProfile(updated);

      if (!mounted) return;

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم تحديث الملف الشخصي')),
          );
          context.pop();
        case Failure(:final message):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الملف الشخصي'),
        actions: [
          TextButton(
            onPressed: _saving
                ? null
                : () => profileAsync.whenData((p) {
                      if (p != null) _save(p);
                    }),
            child: const Text('حفظ'),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('الملف غير موجود'));
          }
          _initFromProfile(profile);

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _saving ? null : () => _showAvatarSheet(profile),
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 52,
                          backgroundImage: _newAvatar != null
                              ? FileImage(_newAvatar!)
                              : (profile.avatarUrl != null
                                  ? NetworkImage(profile.avatarUrl!)
                                  : null),
                          child: _newAvatar == null && profile.avatarUrl == null
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
                if (_uploadProgress > 0 && _uploadProgress < 1) ...[
                  const SizedBox(height: 12),
                  LinearProgressIndicator(value: _uploadProgress),
                ],
                const SizedBox(height: 24),
                CustomTextField(
                  controller: _nameController,
                  label: 'الاسم الكامل',
                  validator: (v) => Validators.requiredField(v, label: 'الاسم'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _governorate,
                  decoration: const InputDecoration(
                    labelText: 'المحافظة',
                    border: OutlineInputBorder(),
                  ),
                  items: iraqiGovernorates
                      .map(
                        (g) => DropdownMenuItem(
                          value: g.slug,
                          child: Text(g.nameAr),
                        ),
                      )
                      .toList(),
                  onChanged:
                      _saving ? null : (v) => setState(() => _governorate = v),
                  validator: (v) => v == null ? 'اختر المحافظة' : null,
                ),
                const SizedBox(height: 16),
                InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    profile.phone ?? '—',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _cityController,
                  label: 'المدينة',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
