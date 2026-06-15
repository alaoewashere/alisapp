import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/router/app_router.dart';
import '../../../widgets/rate_dialog.dart';
import '../../profile/data/profile_repository.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../core/utils/phone_links.dart';
import '../../../shared/models/listing_model.dart';
import '../../chat/providers/chat_provider.dart';
import '../widgets/listing_owner_package_panel.dart';
import '../providers/listing_detail_provider.dart';

const _whatsappGreen = Color(0xFF25D366);

class ListingDetailBottomBar extends ConsumerWidget {
  const ListingDetailBottomBar({
    super.key,
    required this.listing,
    required this.isOwner,
    this.onShareWhatsApp,
    this.shareEnabled = true,
  });

  final ListingModel listing;
  final bool isOwner;
  final VoidCallback? onShareWhatsApp;
  final bool shareEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: isOwner
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ListingOwnerPackagePanel(listing: listing),
                    _OwnerActions(
                      listing: listing,
                      onShareWhatsApp: onShareWhatsApp,
                      shareEnabled: shareEnabled,
                    ),
                  ],
                )
              : _BuyerActions(
                  listing: listing,
                  onShareWhatsApp: onShareWhatsApp,
                  shareEnabled: shareEnabled,
                ),
        ),
      ),
    );
  }
}

class _BuyerActions extends ConsumerWidget {
  const _BuyerActions({
    required this.listing,
    this.onShareWhatsApp,
    this.shareEnabled = true,
  });

  final ListingModel listing;
  final VoidCallback? onShareWhatsApp;
  final bool shareEnabled;

  bool get _hasPhone =>
      listing.sellerPhone != null && listing.sellerPhone!.trim().isNotEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        if (_hasPhone) ...[
          Expanded(
            child: _ActionButton(
              label: 'مراسلة',
              icon: Icons.chat,
              backgroundColor: _whatsappGreen.withValues(alpha: 0.12),
              foregroundColor: _whatsappGreen,
              borderColor: _whatsappGreen.withValues(alpha: 0.4),
              onPressed: () => _openWhatsApp(context),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ActionButton(
              label: 'اتصال',
              icon: Icons.phone_outlined,
              backgroundColor: Theme.of(context).colorScheme.surface,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              borderColor: Theme.of(context).colorScheme.outline,
              onPressed: () => _openPhone(context),
            ),
          ),
          const SizedBox(width: 8),
        ],
        if (onShareWhatsApp != null) ...[
          Expanded(
            child: _ActionButton(
              label: 'واتساب',
              icon: Icons.share_rounded,
              backgroundColor: _whatsappGreen,
              foregroundColor: Colors.white,
              onPressed: shareEnabled ? onShareWhatsApp : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _startChatWithSeller(context, ref),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(
              'راسل البائع',
              style: GoogleFonts.cairo(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              minimumSize: const Size(0, 56),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openWhatsApp(BuildContext context) async {
    final phone = listing.sellerPhone;
    if (phone == null || phone.isEmpty) return;

    final launched = await launchWhatsApp(
      phone,
      message: 'مرحباً، أنا مهتم بإعلانك: ${listingDisplayTitle(listing)}',
    );
    if (!launched && context.mounted) {
      _showSnack(context, 'واتساب غير مثبت');
    }
  }

  Future<void> _openPhone(BuildContext context) async {
    final phone = listing.sellerPhone;
    if (phone == null || phone.isEmpty) return;

    final launched = await launchPhoneCall(phone);
    if (!launched && context.mounted) {
      _showSnack(context, 'تعذّر فتح تطبيق الاتصال');
    }
  }

  Future<void> _startChatWithSeller(BuildContext context, WidgetRef ref) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }
    if (listing.userId == userId) {
      _showSnack(context, 'لا يمكنك مراسلة نفسك');
      return;
    }
    try {
      final conversation =
          await ref.read(chatNotifierProvider.notifier).startChatFromListing(
                listingId: listing.id,
                sellerId: listing.userId,
                listingTitle: listingDisplayTitle(listing),
              );
      if (context.mounted) context.push('/chat/${conversation.id}');
    } catch (_) {
      if (context.mounted) _showSnack(context, 'تعذّر فتح المحادثة');
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _OwnerActions extends ConsumerWidget {
  const _OwnerActions({
    required this.listing,
    this.onShareWhatsApp,
    this.shareEnabled = true,
  });

  final ListingModel listing;
  final VoidCallback? onShareWhatsApp;
  final bool shareEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loading = ref.watch(listingDetailActionsProvider).isLoading;

    return Row(
      children: [
        if (onShareWhatsApp != null) ...[
          Expanded(
            child: _ActionButton(
              label: 'واتساب',
              icon: Icons.share_rounded,
              backgroundColor: _whatsappGreen,
              foregroundColor: Colors.white,
              onPressed: shareEnabled ? onShareWhatsApp : null,
            ),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: _ActionButton(
            label: 'تعديل',
            icon: Icons.edit_outlined,
            backgroundColor: Theme.of(context).colorScheme.surface,
            foregroundColor: Theme.of(context).colorScheme.onSurface,
            borderColor: Theme.of(context).colorScheme.outline,
            onPressed: loading
                ? null
                : () => context.push(AppRoutes.editListingPath(listing.id)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'تم البيع',
            icon: Icons.check_circle_outline,
            backgroundColor: Colors.green.withValues(alpha: 0.12),
            foregroundColor: Colors.green.shade700,
            borderColor: Colors.green.withValues(alpha: 0.4),
            onPressed: loading ? null : () => _confirmSold(context, ref),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: 'حذف',
            icon: Icons.delete_outline,
            backgroundColor: Colors.red.withValues(alpha: 0.08),
            foregroundColor: Colors.red,
            borderColor: Colors.red.withValues(alpha: 0.35),
            onPressed: loading ? null : () => _confirmDelete(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSold(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تم البيع'),
        content: const Text('هل تريد وضع علامة "مباع" على هذا الإعلان؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final lastBuyerId = await ref
        .read(listingDetailActionsProvider.notifier)
        .markAsSold(listing.id);
    if (!context.mounted) return;

    ref.invalidate(listingDetailProvider(listing.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم وضع علامة مباع')),
    );

    if (lastBuyerId != null) {
      final buyer = await ref.read(profileRepositoryProvider).getProfile(lastBuyerId);
      if (buyer != null && context.mounted) {
        await showRateDialog(
          context: context,
          ref: ref,
          listingId: listing.id,
          reviewedId: lastBuyerId,
          reviewedName: buyer.fullName,
          reviewedAvatarSeed: buyer.effectiveAvatarSeed,
          subtitle: 'قيّم المشتري',
        );
      }
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('حذف الإعلان'),
        content: const Text('هل أنت متأكد؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref
        .read(listingDetailActionsProvider.notifier)
        .deleteListing(listing.id);
    if (context.mounted) {
      context.go(AppRoutes.home);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الإعلان')),
      );
    }
  }
}

/// Vertical icon + label button with fixed height to avoid RenderFlex overflow.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final hasBorder = borderColor != null;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: hasBorder ? Border.all(color: borderColor!) : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: foregroundColor),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
