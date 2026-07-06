import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/l10n/l10n_provider.dart';
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
  static const _background = Color(0xFF131315);
  static const _fieldBg = Color(0xFF18181A);
  static const _borderInactive = Color(0x26FFFFFF);
  static const _hintOpacity = 0.3;
  static const _subtitleOpacity = 0.55;
  static const _helperOpacity = 0.4;
  static const _skipOpacity = 0.5;
  static const _buttonDisabledOpacity = 0.3;

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
    setState(() {});
    _debounce?.cancel();
    if (text.isEmpty) {
      setState(() => _availabilityState = UsernameState.idle);
      return;
    }
    if (!isValidUsernameFormat(normalizeUsername(text))) {
      setState(() => _availabilityState = UsernameState.tooShort);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () {
      _checkAvailability(text);
    });
  }

  Future<void> _checkAvailability(String username) async {
    final normalized = normalizeUsername(username);
    if (!isValidUsernameFormat(normalized)) {
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

  bool get _hasUsernameText => _usernameController.text.trim().isNotEmpty;

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
        SnackBar(content: Text(ref.read(appLocalizationsProvider).genericErrorRetry)),
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
    if (_focused) return AppColors.volt;
    return _borderInactive;
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _background,
        resizeToAvoidBottomInset: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: GestureDetector(
                                onTap: _isSaving ? null : _showAvatarPicker,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.volt,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: UserAvatar(
                                      avatarSeed: _avatarSeed,
                                      size: 90,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 32),
                            Text(
                              strings.usernameSetupTitle,
                              textAlign: TextAlign.center,
                              style: AppFonts.cairo(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              strings.usernameSetupSubtitle,
                              textAlign: TextAlign.center,
                              style: AppFonts.cairo(
                                fontSize: 14,
                                color: Colors.white
                                    .withValues(alpha: _subtitleOpacity),
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 36),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: _fieldBg,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _borderColor,
                                  width: 1.5,
                                ),
                              ),
                              child: Directionality(
                                textDirection: TextDirection.ltr,
                                child: TextField(
                                  controller: _usernameController,
                                  focusNode: _focusNode,
                                  maxLength: 20,
                                  keyboardType: TextInputType.text,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9_]'),
                                    ),
                                  ],
                                  style: AppFonts.cairo(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                  decoration: InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.zero,
                                    prefixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Text(
                                        '@',
                                        style: AppFonts.cairo(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.volt,
                                        ),
                                      ),
                                    ),
                                    prefixIconConstraints:
                                        const BoxConstraints(
                                      minWidth: 0,
                                      minHeight: 0,
                                    ),
                                    hintText: strings.usernameHint,
                                    hintStyle: AppFonts.cairo(
                                      fontSize: 16,
                                      color: Colors.white
                                          .withValues(alpha: _hintOpacity),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            if (_availabilityState != UsernameState.idle) ...[
                              const SizedBox(height: 8),
                              UsernameAvailabilityIndicator(
                                state: _availabilityState,
                              ),
                            ],
                            const SizedBox(height: 8),
                            Text(
                              strings.usernameFormatRules,
                              textAlign: TextAlign.center,
                              style: AppFonts.cairo(
                                fontSize: 12,
                                color: Colors.white
                                    .withValues(alpha: _helperOpacity),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _canContinue ? _saveAndContinue : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: _hasUsernameText
                              ? AppColors.volt
                              : AppColors.volt
                                  .withValues(alpha: _buttonDisabledOpacity),
                          disabledBackgroundColor: _hasUsernameText
                              ? AppColors.volt
                              : AppColors.volt
                                  .withValues(alpha: _buttonDisabledOpacity),
                          foregroundColor: _background,
                          disabledForegroundColor: _background,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: _isSaving
                            ? SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: _background,
                                ),
                              )
                            : Text(
                                strings.continueAction,
                                style: AppFonts.cairo(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: _background,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: _isSaving ? null : _skip,
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Colors.white.withValues(alpha: _skipOpacity),
                        ),
                        child: Text(
                          strings.skipForNow,
                          style: AppFonts.cairo(
                            fontSize: 14,
                            color:
                                Colors.white.withValues(alpha: _skipOpacity),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
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
