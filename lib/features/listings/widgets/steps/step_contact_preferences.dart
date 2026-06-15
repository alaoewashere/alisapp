import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);

    final isEdit = ref.watch(isEditListingFormProvider);

    final content = Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'التواصل',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const _SectionHeader(label: 'معلومات التواصل'),
          const SizedBox(height: 4),
          profileAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text('$e', style: TextStyle(color: theme.colorScheme.error)),
            ),
            data: (profile) {
              final name = profile?.fullName.trim().isNotEmpty == true
                  ? profile!.fullName
                  : '—';
              final phone = profile?.phone?.trim().isNotEmpty == true
                  ? profile!.phone!
                  : '—';

              return Column(
                children: [
                  _ContactInfoRow(
                    value: name,
                    onEdit: () => _openEditProfile(context, ref),
                  ),
                  const Divider(height: 1),
                  _ContactInfoRow(
                    value: phone,
                    onEdit: () => _openEditProfile(context, ref),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            label: 'تفضيلات التواصل',
            trailing: IconButton(
              icon: Icon(
                Icons.help_outline,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              onPressed: () => _showContactPreferenceHelp(context),
            ),
          ),
          const SizedBox(height: 8),
          ...ListingContactPreference.values.map(
            (option) => RadioListTile<ListingContactPreference>(
              value: option,
              groupValue: state.contactPreference,
              onChanged: (value) {
                if (value != null) notifier.setContactPreference(value);
              },
              title: Text(option.labelAr),
              contentPadding: EdgeInsets.zero,
              visualDensity: VisualDensity.compact,
            ),
          ),
          if (state.error != null) ...[
            const SizedBox(height: 12),
            Text(
              state.error!,
              style: TextStyle(color: theme.colorScheme.error),
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

  void _showContactPreferenceHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تفضيلات التواصل'),
        content: const Text(
          'اختر الطريقة التي يمكن للمشترين التواصل معك من خلالها على هذا الإعلان.\n\n'
          '• هاتف ورسائل: يمكن التواصل عبر الهاتف والرسائل داخل التطبيق\n'
          '• هاتف فقط: يظهر رقم الهاتف دون رسائل داخل التطبيق\n'
          '• رسائل فقط: التواصل عبر الرسائل داخل التطبيق فقط',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    this.trailing,
  });

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _ContactInfoRow extends StatelessWidget {
  const _ContactInfoRow({
    required this.value,
    required this.onEdit,
  });

  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'تعديل',
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
