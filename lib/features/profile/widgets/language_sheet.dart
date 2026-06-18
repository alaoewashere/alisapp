import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_fonts.dart';
import '../../../l10n/app_localizations.dart';

void showLanguageSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const LanguageSheet(),
  );
}

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  static const _options = <({String code, String labelKey})>[
    (code: 'ar', labelKey: 'languageArabic'),
    (code: 'en', labelKey: 'languageEnglish'),
    (code: 'ku', labelKey: 'languageKurdish'),
    (code: 'tr', labelKey: 'languageTurkish'),
  ];

  String _labelFor(AppLocalizations strings, String key) {
    return switch (key) {
      'languageArabic' => strings.languageArabic,
      'languageEnglish' => strings.languageEnglish,
      'languageKurdish' => strings.languageKurdish,
      'languageTurkish' => strings.languageTurkish,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final currentCode =
        normalizeAppLocale(ref.watch(localeProvider)).languageCode;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.canvas,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.glassBorder)),
      ),
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.glassBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            strings.chooseLanguage,
            textAlign: TextAlign.center,
            style: AppFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.pureWhite,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < _options.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _LanguageOptionTile(
              label: _labelFor(strings, _options[i].labelKey),
              selected: currentCode == _options[i].code,
              onTap: () => _select(context, ref, Locale(_options[i].code)),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _select(
    BuildContext context,
    WidgetRef ref,
    Locale locale,
  ) async {
    await ref.read(localeProvider.notifier).setLocale(locale);
    if (context.mounted) Navigator.pop(context);
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

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
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
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
              if (selected)
                Container(
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
                )
              else
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder, width: 1.5),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
