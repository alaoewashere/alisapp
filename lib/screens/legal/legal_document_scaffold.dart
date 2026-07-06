import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/app_back_button.dart';

class LegalSection {
  const LegalSection({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

/// Shared scrollable legal document layout for terms and privacy screens.
class LegalDocumentScaffold extends StatelessWidget {
  const LegalDocumentScaffold({
    super.key,
    required this.title,
    required this.sections,
    required this.textDirection,
  });

  static const backgroundColor = Color(0xFF131315);

  final String title;
  final List<LegalSection> sections;
  final TextDirection textDirection;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: backgroundColor,
          foregroundColor: AppColors.pureWhite,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          leading: AppBackButton(
            onPressed: () => Navigator.maybePop(context),
          ),
          title: Text(
            title,
            style: AppFonts.sans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.pureWhite,
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          itemCount: sections.length,
          itemBuilder: (context, index) {
            final section = sections[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == sections.length - 1 ? 0 : 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    section.title,
                    style: AppFonts.sans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.pureWhite,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    section.body,
                    style: AppFonts.sans(
                      fontSize: 14,
                      color: AppColors.pureWhite.withValues(alpha: 0.7),
                      height: 1.7,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

List<LegalSection> buildLegalSections(
  List<({String title, String body})> entries,
) {
  return entries
      .map((e) => LegalSection(title: e.title, body: e.body))
      .toList(growable: false);
}
