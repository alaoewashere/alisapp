import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_provider.dart';
import '../../../core/providers/locale_provider.dart';

void showLanguageSheet(BuildContext context, WidgetRef ref) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const LanguageSheet(),
  );
}

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final locale = ref.watch(localeProvider);
    final currentCode = normalizeAppLocale(locale).languageCode;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.chooseLanguage,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _LanguageOption(
              label: strings.languageArabic,
              selected: currentCode == 'ar',
              onTap: () => _select(context, ref, const Locale('ar')),
            ),
            _LanguageOption(
              label: strings.languageKurdish,
              selected: currentCode == 'ku',
              onTap: () => _select(context, ref, const Locale('ku')),
            ),
            _LanguageOption(
              label: strings.languageEnglish,
              selected: currentCode == 'en',
              onTap: () => _select(context, ref, const Locale('en')),
            ),
          ],
        ),
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

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      value: label,
      groupValue: selected ? label : null,
      onChanged: (_) => onTap(),
      title: Text(label),
    );
  }
}
