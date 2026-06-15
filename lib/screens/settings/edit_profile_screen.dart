import 'dart:async';

import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/dicebear_avatars.dart';
import '../../theme/app_form_fields.dart';
import '../../theme/app_text_styles.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/utils/result.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/username_utils.dart';
import '../../features/profile/providers/profile_provider.dart';
import '../../shared/models/profile_model.dart';
import '../../shared/widgets/username_availability_indicator.dart';
import '../../widgets/avatar_picker_sheet.dart';
import '../../widgets/user_avatar.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  static const _pageBg = Color(0xFFF5F5F5);
  static const _textDark = Color(0xFF111111);
  static const _disabledText = Color(0xFFAAAAAA);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _usernameController = TextEditingController();

  late Country _selectedCountry;
  var _loading = true;
  var _isSaving = false;
  String _avatarSeed = DiceBearAvatars.defaultSeed;
  ProfileModel? _profile;
  String? _originalUsername;
  UsernameState _usernameState = UsernameState.idle;
  Timer? _usernameDebounce;

  @override
  void initState() {
    super.initState();
    _selectedCountry = Country.parse('IQ');
    _usernameController.addListener(_onUsernameChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProfile());
  }

  @override
  void dispose() {
    _usernameDebounce?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _usernameController.text;
    _usernameDebounce?.cancel();

    if (text.isEmpty) {
      setState(() => _usernameState = UsernameState.idle);
      return;
    }

    final normalized = normalizeUsername(text);
    if (normalizeUsername(_originalUsername ?? '') == normalized) {
      setState(() => _usernameState = UsernameState.available);
      return;
    }

    if (text.length < 3) {
      setState(() => _usernameState = UsernameState.tooShort);
      return;
    }

    _usernameDebounce = Timer(const Duration(milliseconds: 600), () {
      _checkUsernameAvailability(text);
    });
  }

  Future<void> _checkUsernameAvailability(String username) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final normalized = normalizeUsername(username);
    if (!isValidUsernameLength(normalized)) {
      if (mounted) setState(() => _usernameState = UsernameState.tooShort);
      return;
    }

    if (normalizeUsername(_originalUsername ?? '') == normalized) {
      if (mounted) setState(() => _usernameState = UsernameState.available);
      return;
    }

    setState(() => _usernameState = UsernameState.checking);

    try {
      final available = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(normalized, excludeUserId: userId);
      if (!mounted) return;
      setState(() {
        _usernameState =
            available ? UsernameState.available : UsernameState.taken;
      });
    } catch (_) {
      if (mounted) setState(() => _usernameState = UsernameState.idle);
    }
  }

  Future<void> _loadProfile() async {
    try {
      final userId = ref.read(currentUserIdProvider);
      final user = supabase.auth.currentUser;
      if (userId == null || user == null) {
        if (mounted) context.pop();
        return;
      }

      final profile = await ref.read(profileRepositoryProvider).getProfile(userId);
      if (!mounted) return;

      if (profile == null) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف غير موجود')),
        );
        return;
      }

      setState(() {
        _profile = profile;
        _nameController.text = profile.fullName;
        _emailController.text = user.email ?? '';
        _usernameController.text = profile.username ?? '';
        _originalUsername = profile.username;
        _avatarSeed = profile.effectiveAvatarSeed;
        _initPhoneFromE164(profile.phone);
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذّر تحميل الملف الشخصي')),
        );
      }
    }
  }

  void _initPhoneFromE164(String? phone) {
    if (phone == null || phone.trim().isEmpty) return;
    final e164 = Validators.normalizeE164(phone);
    for (final country in ['IQ', 'SA', 'AE', 'JO', 'KW']) {
      final c = Country.parse(country);
      final dial = '+${c.phoneCode}';
      if (e164.startsWith(dial)) {
        _selectedCountry = c;
        _phoneController.text = e164.substring(dial.length);
        return;
      }
    }
    _phoneController.text = e164.replaceFirst('+', '');
  }

  String? _buildPhoneE164() {
    final local = _phoneController.text.trim();
    if (local.isEmpty) return null;
    final localDigits = Validators.normalizeLocalDigits(
      local,
      _selectedCountry.countryCode,
    );
    final error = Validators.localPhone(localDigits, _selectedCountry.countryCode);
    if (error != null) return null;
    return Validators.formatE164(
      '+${_selectedCountry.phoneCode}',
      localDigits,
    );
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        bottomSheetHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      onSelect: (Country country) {
        setState(() => _selectedCountry = country);
      },
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

    final phoneE164 = _buildPhoneE164();
    if (_phoneController.text.trim().isNotEmpty && phoneE164 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('رقم الهاتف غير صالح')),
      );
      return;
    }

    final usernameRaw = _usernameController.text.trim();
    String? usernameToSave;
    if (usernameRaw.isNotEmpty) {
      final normalized = normalizeUsername(usernameRaw);
      final unchanged =
          normalizeUsername(_originalUsername ?? '') == normalized;
      if (!unchanged) {
        if (_usernameState == UsernameState.taken) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اسم المستخدم محجوز')),
          );
          return;
        }
        if (_usernameState == UsernameState.checking ||
            _usernameState == UsernameState.tooShort ||
            _usernameState == UsernameState.idle) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('اختر اسم مستخدم صالح')),
          );
          return;
        }
      }
      usernameToSave = normalized;
    }

    setState(() => _isSaving = true);

    try {
      final updated = profile.copyWith(
        fullName: _nameController.text.trim(),
        phone: phoneE164,
        username: usernameToSave,
        avatarSeed: _avatarSeed,
      );

      final result =
          await ref.read(profileNotifierProvider.notifier).updateProfile(updated);

      if (!mounted) return;
      setState(() => _isSaving = false);

      switch (result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'تم حفظ التغييرات بنجاح',
                style: GoogleFonts.cairo(fontWeight: FontWeight.w600),
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        case Failure():
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('حدث خطأ أثناء الحفظ')),
          );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء الحفظ')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _textDark,
              size: 20,
            ),
            onPressed: _isSaving ? null : () => context.pop(),
          ),
          title: Text(
            'تعديل الملف الشخصي',
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
                      'حفظ',
                      style: GoogleFonts.cairo(
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
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AvatarSection(
                        avatarSeed: _avatarSeed,
                        onTap: _isSaving ? null : _showAvatarPicker,
                      ),
                      const SizedBox(height: 28),
                      _EditField(
                        label: 'الاسم الكامل',
                        child: TextFormField(
                          controller: _nameController,
                          style: AppTextStyles.input,
                          textInputAction: TextInputAction.next,
                          validator: (v) =>
                              v == null || v.trim().isEmpty ? 'أدخل الاسم' : null,
                          decoration: AppFormDecorations.underline(
                            hintText: 'الاسم الكامل',
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _EditField(
                            label: 'اسم المستخدم',
                            child: Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextFormField(
                                controller: _usernameController,
                                maxLength: 30,
                                keyboardType: TextInputType.text,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                    RegExp(r'[a-zA-Z0-9_]'),
                                  ),
                                ],
                                style: AppTextStyles.input,
                                decoration: AppFormDecorations.underline(
                                  hintText: 'username',
                                ).copyWith(
                                  counterText: '',
                                  prefixText: '@ ',
                                  prefixStyle: AppTextStyles.caption.copyWith(
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (_usernameState != UsernameState.idle)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: UsernameAvailabilityIndicator(
                                state: _usernameState,
                              ),
                            ),
                        ],
                      ),
                      _EditField(
                        label: 'البريد الإلكتروني',
                        child: TextFormField(
                          controller: _emailController,
                          enabled: false,
                          style: AppTextStyles.input.copyWith(color: _disabledText),
                          keyboardType: TextInputType.emailAddress,
                          decoration: AppFormDecorations.underline(),
                        ),
                      ),
                      _EditField(
                        label: 'رقم الهاتف',
                        child: Directionality(
                          textDirection: TextDirection.ltr,
                          child: Row(
                            children: [
                              Material(
                                color: const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(8),
                                child: InkWell(
                                  onTap: _isSaving ? null : _pickCountry,
                                  borderRadius: BorderRadius.circular(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _selectedCountry.flagEmoji,
                                          style: const TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${_selectedCountry.phoneCode}',
                                          style: GoogleFonts.cairo(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: _textDark,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: AppTextStyles.input,
                                  decoration: AppFormDecorations.underline(
                                    hintText: 'رقم الهاتف',
                                  ),
                                ),
                              ),
                            ],
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

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.avatarSeed,
    required this.onTap,
  });

  final String avatarSeed;
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
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
            'تغيير الصورة',
            style: GoogleFonts.cairo(
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
  const _EditField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppFieldGroupLabel(label: label, required: true),
          AppFormFieldGroup(children: [child]),
        ],
      ),
    );
  }
}
