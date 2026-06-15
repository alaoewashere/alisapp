import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/username_prefs.dart';
import '../../core/utils/auth_navigation.dart';
import '../../core/supabase/supabase_client.dart';
import '../../core/utils/username_utils.dart';
import '../../core/constants/dicebear_avatars.dart';
import '../../features/profile/data/profile_repository.dart';
import '../../shared/widgets/username_availability_indicator.dart';
import '../../widgets/avatar_picker_sheet.dart';
import '../../widgets/user_avatar.dart';

class UsernameSetupScreen extends ConsumerStatefulWidget {
  const UsernameSetupScreen({super.key});

  @override
  ConsumerState<UsernameSetupScreen> createState() =>
      _UsernameSetupScreenState();
}

class _UsernameSetupScreenState extends ConsumerState<UsernameSetupScreen>
    with SingleTickerProviderStateMixin {
  static const _textDark = Color(0xFF111111);
  static const _textMuted = Color(0xFF888888);
  static const _hintColor = Color(0xFFBBBBBB);
  static const _rulesColor = Color(0xFFAAAAAA);
  static const _borderDefault = Color(0xFFE0E0E0);
  static const _disabledButton = Color(0xFFCCCCCC);

  final _usernameController = TextEditingController();
  final _focusNode = FocusNode();

  late final AnimationController _entranceController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  Timer? _debounce;
  UsernameState _availabilityState = UsernameState.idle;
  var _isSaving = false;
  var _focused = false;
  late String _avatarSeed;

  @override
  void initState() {
    super.initState();
    _avatarSeed = DiceBearAvatars
        .seeds[Random().nextInt(DiceBearAvatars.seeds.length)];
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutCubic),
    );
    _entranceController.forward();

    _focusNode.addListener(() {
      setState(() => _focused = _focusNode.hasFocus);
    });
    _usernameController.addListener(_onUsernameChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _usernameController.dispose();
    _focusNode.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  void _onUsernameChanged() {
    final text = _usernameController.text;
    _debounce?.cancel();
    if (text.isEmpty) {
      setState(() => _availabilityState = UsernameState.idle);
      return;
    }
    if (text.length < 3) {
      setState(() => _availabilityState = UsernameState.tooShort);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkAvailability(text);
    });
  }

  Future<void> _checkAvailability(String username) async {
    final normalized = normalizeUsername(username);
    if (!isValidUsernameLength(normalized)) {
      if (mounted) {
        setState(() => _availabilityState = UsernameState.tooShort);
      }
      return;
    }

    setState(() => _availabilityState = UsernameState.checking);

    try {
      final available = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(normalized);
      if (!mounted) return;
      setState(() {
        _availabilityState =
            available ? UsernameState.available : UsernameState.taken;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _availabilityState = UsernameState.idle);
    }
  }

  bool get _canContinue {
    final text = _usernameController.text.trim();
    return text.isNotEmpty &&
        _availabilityState == UsernameState.available &&
        !_isSaving;
  }

  Future<void> _saveAndContinue() async {
    if (!_canContinue) return;

    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    setState(() => _isSaving = true);

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateUsername(userId, _usernameController.text);
      await ref.read(profileRepositoryProvider).updateAvatarSeed(
            userId,
            _avatarSeed,
          );

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(usernameSetupSkippedKey);

      ref.invalidate(currentProfileProvider);

      if (!mounted) return;
      setState(() => _isSaving = false);
      final route = await resolvePostAuthRoute(ref);
      if (mounted) context.go(route);
    } catch (_) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ، حاول مجدداً')),
      );
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(usernameSetupSkippedKey, true);
    if (!mounted) return;
    final route = await resolvePostAuthRoute(ref);
    if (mounted) context.go(route);
  }

  Future<void> _showAvatarPicker() async {
    await showAvatarPickerSheet(
      context,
      currentSeed: _avatarSeed,
      onSelected: (seed) => setState(() => _avatarSeed = seed),
    );
  }

  Color get _borderColor {
    if (_availabilityState == UsernameState.taken) return Colors.red;
    if (_focused) return AppColors.primary;
    return _borderDefault;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    Center(
                      child: GestureDetector(
                        onTap: _isSaving ? null : _showAvatarPicker,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            UserAvatar(avatarSeed: _avatarSeed, size: 88),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.edit,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: Image.asset(
                        AppAssets.appLogo,
                        width: 56,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'اختر اسم المستخدم',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'سيظهر هذا الاسم في ملفك الشخصي وإعلاناتك',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 14,
                          color: _textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Container(
                      height: 56,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _borderColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Directionality(
                        textDirection: TextDirection.ltr,
                        child: TextField(
                          controller: _usernameController,
                          focusNode: _focusNode,
                          maxLength: 30,
                          keyboardType: TextInputType.text,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9_]'),
                            ),
                          ],
                          style: GoogleFonts.cairo(
                            fontSize: 16,
                            color: _textDark,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            isDense: true,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Text(
                                '@',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  color: _textMuted,
                                ),
                              ),
                            ),
                            prefixIconConstraints: const BoxConstraints(
                              minWidth: 0,
                              minHeight: 0,
                            ),
                            hintText: 'اسم_المستخدم',
                            hintStyle: GoogleFonts.cairo(
                              fontSize: 16,
                              color: _hintColor,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    UsernameAvailabilityIndicator(state: _availabilityState),
                    const SizedBox(height: 16),
                    Text(
                      'يمكن استخدام الأحرف الإنجليزية والأرقام والشرطة السفلية فقط',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.cairo(
                        fontSize: 12,
                        color: _rulesColor,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: FilledButton(
                        onPressed: _canContinue ? _saveAndContinue : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor: _disabledButton,
                          foregroundColor: Colors.white,
                          disabledForegroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'متابعة',
                                style: GoogleFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _isSaving ? null : _skip,
                        child: Text(
                          'تخطى الآن',
                          style: GoogleFonts.cairo(
                            fontSize: 13,
                            color: _textMuted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
