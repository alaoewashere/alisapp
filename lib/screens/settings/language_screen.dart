import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../core/router/app_router.dart';
import '../../core/theme/app_fonts.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/app_logo.dart';
import '../../shared/widgets/sello_app_bar.dart';

class LanguageScreen extends ConsumerStatefulWidget {
  const LanguageScreen({super.key, this.isOnboarding = true});

  /// First launch flow — no AppBar, continue navigates to login.
  final bool isOnboarding;

  @override
  ConsumerState<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends ConsumerState<LanguageScreen> {
  static const _languages = <_LanguageOptionData>[
    _LanguageOptionData(code: 'ar', flag: '🇮🇶', label: 'العربية'),
    _LanguageOptionData(code: 'en', flag: '🇬🇧', label: 'English'),
    _LanguageOptionData(code: 'ku', flag: '🇹🇯', label: 'کوردی'),
    _LanguageOptionData(code: 'tr', flag: '🇹🇷', label: 'Türkçe'),
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
    return index >= 0 ? index : 0;
  }

  String get _selectedCode => _languages[_selectedIndex].code;

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

  String _continueLabel(AppLocalizations strings) {
    return switch (_selectedCode) {
      'en' => strings.continueAction,
      'tr' => strings.continueAction,
      'ku' => 'بەردەوامبە',
      _ => strings.continueAction,
    };
  }

  String _welcomeTitle() {
    return switch (_selectedCode) {
      'en' => 'Welcome to Sello',
      'tr' => 'Sello\'ya Hoş Geldiniz',
      'ku' => 'بەخێربێیت بۆ سێلو',
      _ => 'مرحباً بك في سيلو',
    };
  }

  String _chooseSubtitle() {
    return switch (_selectedCode) {
      'en' => 'Choose your language',
      'tr' => 'Dilinizi seçin',
      'ku' => 'زمانەکەت هەڵبژێرە',
      _ => 'اختر لغتك',
    };
  }

  String _settingsHint() {
    return switch (_selectedCode) {
      'en' => 'You can change the language anytime in Settings',
      'tr' => 'Dili istediğiniz zaman Ayarlar\'dan değiştirebilirsiniz',
      'ku' => 'دەتوانیت زمان لە هەر کاتێکدا لە ڕێکخستنەکان بگۆڕیت',
      _ => 'يمكنك تغيير اللغة في أي وقت من الإعدادات',
    };
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appLocalizationsProvider);
    final textDirection = _selectedCode == 'en' || _selectedCode == 'tr'
        ? TextDirection.ltr
        : TextDirection.rtl;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: AppColors.canvas,
        appBar: widget.isOnboarding
            ? null
            : SelloAppBar(
                title: Text(
                  strings.changeLanguage,
                  style: AppFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      SizedBox(height: widget.isOnboarding ? 48 : 24),
                      if (widget.isOnboarding) ...[
                        const AppLogo(size: 56),
                        const SizedBox(height: 24),
                      ],
                      Text(
                        widget.isOnboarding
                            ? _welcomeTitle()
                            : strings.chooseLanguage,
                        textAlign: TextAlign.center,
                        style: AppFonts.cairo(
                          fontSize: widget.isOnboarding ? 24 : 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.pureWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.isOnboarding
                            ? _chooseSubtitle()
                            : strings.changeLanguage,
                        textAlign: TextAlign.center,
                        style: AppFonts.cairo(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: widget.isOnboarding ? 32 : 24),
                      for (var i = 0; i < _languages.length; i++) ...[
                        if (i > 0) const SizedBox(height: 12),
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
              if (widget.isOnboarding)
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                  child: Text(
                    _settingsHint(),
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 12,
                      color: AppColors.textMuted,
                      height: 1.4,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _continue,
                    child: Text(
                      widget.isOnboarding
                          ? _continueLabel(strings)
                          : strings.save,
                      style: AppFonts.cairo(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
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
      color: AppColors.fieldCarbon,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: selected ? AppColors.volt : AppColors.glassBorder,
          width: selected ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Text(flag, style: const TextStyle(fontSize: 26)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.cairo(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: AppColors.pureWhite,
                  ),
                ),
              ),
              _SelectionCheck(selected: selected),
            ],
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
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: AppColors.volt,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.check_rounded,
          size: 16,
          color: AppColors.canvas,
        ),
      );
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.glassBorder, width: 1.5),
      ),
    );
  }
}
