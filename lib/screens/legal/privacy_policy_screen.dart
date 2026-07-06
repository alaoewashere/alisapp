import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_provider.dart';
import '../../core/providers/locale_provider.dart';
import '../../l10n/app_localizations.dart';
import 'legal_document_scaffold.dart';

class PrivacyPolicyScreen extends ConsumerWidget {
  const PrivacyPolicyScreen({super.key});

  static List<LegalSection> _sections(AppLocalizations l10n) {
    return buildLegalSections([
      (title: l10n.privacySection1Title, body: l10n.privacySection1Body),
      (title: l10n.privacySection2Title, body: l10n.privacySection2Body),
      (title: l10n.privacySection3Title, body: l10n.privacySection3Body),
      (title: l10n.privacySection4Title, body: l10n.privacySection4Body),
      (title: l10n.privacySection5Title, body: l10n.privacySection5Body),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appLocalizationsProvider);
    final textDirection =
        localeTextDirection(ref.watch(localeProvider));

    return LegalDocumentScaffold(
      title: l10n.privacyTitle,
      sections: _sections(l10n),
      textDirection: textDirection,
    );
  }
}
