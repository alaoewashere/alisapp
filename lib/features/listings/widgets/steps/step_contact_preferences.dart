import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/l10n/enum_localizations.dart';
import '../../../../core/l10n/l10n_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../shared/models/listing_model.dart';
import '../../../profile/data/profile_repository.dart';
import '../../providers/edit_listing_form_mode.dart';
import '../../providers/post_listing_provider.dart';

class StepContactPreferences extends ConsumerWidget {
  const StepContactPreferences({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(postListingProvider);
    final notifier = ref.read(postListingProvider.notifier);
    final profileAsync = ref.watch(currentProfileProvider);
    final strings = ref.watch(appLocalizationsProvider);

    final isEdit = ref.watch(isEditListingFormProvider);

    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            strings.contactTitle,
            style: AppFonts.cairo(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 18),
          _SectionLabel(label: strings.contactInfoSection),
          const SizedBox(height: 8),
          profileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('$e',
                  style: const TextStyle(color: AppColors.rejected)),
            ),
            data: (profile) {
              final name = profile?.fullName.trim().isNotEmpty == true
                  ? profile!.fullName
                  : '—';
              final phone = profile?.phone?.trim().isNotEmpty == true
                  ? profile!.phone!
                  : '—';

              return _Card(
                child: Column(
                  children: [
                    _ContactInfoRow(
                      value: name,
                      onEdit: () => _openEditProfile(context, ref),
                    ),
                    const Divider(height: 1, color: AppColors.glassBorder),
                    _ContactInfoRow(
                      value: phone,
                      isPhone: true,
                      onEdit: () => _openEditProfile(context, ref),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionLabel(
            label: strings.contactPreferencesTitle,
            trailing: GestureDetector(
              onTap: () => _showContactPreferenceHelp(context, strings),
              child: const Icon(
                Icons.help_outline,
                size: 18,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _Card(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0;
                    i < ListingContactPreference.values.length;
                    i++) ...[
                  if (i > 0)
                    const Divider(height: 1, color: AppColors.glassBorder),
                  _PrefOption(
                    label: ListingContactPreference.values[i]
                        .localizedLabel(strings),
                    selected: state.contactPreference ==
                        ListingContactPreference.values[i],
                    onTap: () => notifier.setContactPreference(
                      ListingContactPreference.values[i],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: const TextStyle(color: AppColors.rejected),
            ),
          ],
        ],
      ),
    );

    if (isEdit) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: content,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: content,
    );
  }

  Future<void> _openEditProfile(BuildContext context, WidgetRef ref) async {
    await context.push(AppRoutes.editProfile);
    ref.invalidate(currentProfileProvider);
  }

  void _showContactPreferenceHelp(
    BuildContext context,
    AppLocalizations strings,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(strings.contactPreferencesTitle),
        content: Text(strings.contactPreferencesHelp),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.understood),
          ),
        ],
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.fieldCarbon,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: child,
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppFonts.cairo(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textMuted,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ],
      ],
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.value,
    required this.onEdit,
    this.isPhone = false,
  });

  final String value;
  final VoidCallback onEdit;
  final bool isPhone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              textDirection: isPhone ? TextDirection.ltr : null,
              textAlign: isPhone ? TextAlign.right : TextAlign.start,
              style: AppFonts.cairo(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.volt),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}

class _PrefOption extends StatelessWidget {
  const _PrefOption({
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
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppFonts.cairo(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: selected ? AppColors.volt : AppColors.textDark,
                  ),
                ),
              ),
              // Custom radio dot.
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.volt : AppColors.textMuted,
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: selected
                    ? Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: AppColors.volt,
                          shape: BoxShape.circle,
                        ),
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
