import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'legal_document_scaffold.dart';

class TermsOfUseScreen extends ConsumerWidget {
  const TermsOfUseScreen({super.key});

  static List<LegalSection> _sections(AppLocalizations l10n) {
    return buildLegalSections([
      (title: l10n.termsSection1Title, body: l10n.termsSection1Body),
      (title: l10n.termsSection2Title, body: l10n.termsSection2Body),
      (title: l10n.termsSection3Title, body: l10n.termsSection3Body),
      (title: l10n.termsSection4Title, body: l10n.termsSection4Body),
      (title: l10n.termsSection5Title, body: l10n.termsSection5Body),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsProvider);
    final textDirection =
        localeTextDirection(ref.watch(localeProvider));

    return LegalDocumentScaffold(
      title: l10n.termsTitle,
      sections: _sections(l10n),
      textDirection: textDirection,
    );
  }
}
