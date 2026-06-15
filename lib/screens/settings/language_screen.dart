import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/router/app_router.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key, this.isOnboarding = true});

  /// First launch flow — no AppBar, continue navigates to login.
  final bool isOnboarding;

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  static const _pageBg = Color(0xFFF5F5F5);
  static const _titleColor = Color(0xFF111111);
  static const _subtitleColor = Color(0xFF555555);
  static const _hintColor = Color(0xFF888888);

  static const _languages = <_LanguageOptionData>[
    _LanguageOptionData(code: 'en', flag: '🇬🇧', label: 'English'),
    _LanguageOptionData(code: 'ar', flag: '🇸🇦', label: 'العربية'),
    _LanguageOptionData(code: 'ku', flag: '🟢', label: 'کوردی'),
  ];

  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    final code = normalizeAppLocale(ref.read(localeProvider)).languageCode;
    _selectedIndex = _indexForCode(code);
  }

  int _indexForCode(String code) {
    final index = _languages.indexWhere((lang) => lang.code == code);
    return index >= 0 ? index : 1;
  }

  String get _selectedCode => _languages[_selectedIndex].code;

  String get _continueLabel => switch (_selectedCode) {
        'en' => 'CONTINUE',
        'ku' => 'بەردەوامبە',
        _ => 'متابعة',
      };

  Future<void> _continue() async {
    await ref.read(localeProvider.notifier).setLocale(Locale(_selectedCode));
    if (!mounted) return;

    if (widget.isOnboarding) {
      await ref.read(localeProvider.notifier).markOnboardingComplete();
      if (!mounted) return;
      context.go(AppRoutes.phone);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: _pageBg,
        appBar: widget.isOnboarding
            ? null
            : AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                scrolledUnderElevation: 0,
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _titleColor,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  'اللغة',
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _titleColor,
                  ),
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(height: widget.isOnboarding ? 80 : 32),
                      Text(
                        'مرحباً بك في سيلو',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: _titleColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'اختر لغتك',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.cairo(
                          fontSize: 18,
                          color: _subtitleColor,
                        ),
                      ),
                      const SizedBox(height: 48),
                      for (var i = 0; i < _languages.length; i++) ...[
                        if (i > 0) const SizedBox(height: 14),
                        _LanguageOptionTile(
                          flag: _languages[i].flag,
                          label: _languages[i].label,
                          selected: _selectedIndex == i,
                          onTap: () => setState(() => _selectedIndex = i),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 16, 40, 16),
                child: Text(
                  'يمكنك تغيير اللغة في أي وقت من الإعدادات',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 13,
                    color: _hintColor,
                    height: 1.4,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                child: SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF111111),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _continueLabel,
                      style: GoogleFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionData {
  const _LanguageOptionData({
    required this.code,
    required this.flag,
    required this.label,
  });

  final String code;
  final String flag;
  final String label;
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.flag,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flag;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: selected
            ? BorderSide.none
            : const BorderSide(color: Color(0xFFDDDDDD), width: 1.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 58,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(flag, style: const TextStyle(fontSize: 28)),
                Expanded(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.cairo(
                      fontSize: 16,
                      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
                      color: selected ? Colors.white : const Color(0xFF111111),
                    ),
                  ),
                ),
                _SelectionCheck(selected: selected),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SelectionCheck extends StatelessWidget {
  const _SelectionCheck({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    if (selected) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check,
          size: 16,
          color: AppColors.primary,
        ),
      );
    }

    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFFCCCCCC),
          width: 1.5,
        ),
      ),
    );
  }
}
