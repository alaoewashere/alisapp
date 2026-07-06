import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/l10n/l10n_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../widgets/rate_dialog.dart';
import '../../chat/data/chat_repository.dart';
import '../../../widgets/user_avatar.dart';
import '../../../core/supabase/supabase_client.dart';
import '../../../core/utils/listing_display_title.dart';
import '../../../shared/models/listing_model.dart';
import '../../chat/providers/chat_provider.dart';
import '../widgets/listing_owner_package_panel.dart';
import '../providers/listing_detail_provider.dart';

const _voltGlow = Color(0xFFD4FF3A);

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
    final pending = listing.isPendingModeration;

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
                    if (pending)
                      const _PendingOwnerNotice()
                    else
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

class _PendingOwnerNotice extends ConsumerWidget {
  const _PendingOwnerNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_clock_rounded, color: scheme.primary, size: 28),
          const SizedBox(height: 10),
          Text(
            strings.pendingApprovalTitle,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            strings.pendingApprovalBody,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appLocalizationsProvider);

    final hasWhatsApp = (listing.isProListing || listing.isPremiumListing) &&
        listing.sellerPhone != null &&
        listing.sellerPhone!.isNotEmpty;

    final chatButton = Expanded(
      child: SizedBox(
        height: 56,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _startChatWithSeller(context, ref),
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              decoration: BoxDecoration(
                color: _voltGlow,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _voltGlow.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                  BoxShadow(
                    color: _voltGlow.withValues(alpha: 0.25),
                    blurRadius: 32,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 18, color: AppColors.canvas),
                  const SizedBox(width: 8),
                  Text(
                    strings.messageSeller,
                    style: AppFonts.cairo(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.canvas,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (!hasWhatsApp) {
      return Row(children: [chatButton]);
    }

    return Row(
      children: [
        _WhatsAppButton(phone: listing.sellerPhone!),
        const SizedBox(width: 10),
        chatButton,
      ],
    );
  }

  Future<void> _startChatWithSeller(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appLocalizationsProvider);
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) {
      await requireAuth(context, ref);
      return;
    }
    if (listing.userId == userId) {
      _showSnack(context, strings.cannotMessageSelf);
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
      if (context.mounted) _showSnack(context, strings.openChatFailed);
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
    final strings = ref.watch(appLocalizationsProvider);
    final loading = ref.watch(listingDetailActionsProvider).isLoading;

    const soldGreen = Color(0xFF34C759);
    const deleteRed = Color(0xFFFF453A);

    // Published listings can't be edited — owners can mark sold or delete only.
    return Row(
      children: [
        // Sold — primary owner action.
        Expanded(
          flex: 6,
          child: _ActionButton(
            label: strings.markAsSoldAction,
            icon: Icons.check_circle_outline,
            backgroundColor: soldGreen.withValues(alpha: 0.14),
            foregroundColor: soldGreen,
            borderColor: soldGreen.withValues(alpha: 0.45),
            onPressed: loading ? null : () => _confirmSold(context, ref),
          ),
        ),
        const SizedBox(width: 10),
        // Delete — destructive.
        Expanded(
          flex: 4,
          child: _ActionButton(
            label: strings.delete,
            icon: Icons.delete_outline,
            backgroundColor: deleteRed.withValues(alpha: 0.10),
            foregroundColor: deleteRed,
            borderColor: deleteRed.withValues(alpha: 0.35),
            onPressed: loading ? null : () => _confirmDelete(context, ref),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmSold(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appLocalizationsProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.markAsSoldTitle),
        content: Text(strings.markAsSoldBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.confirm),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref
        .read(listingDetailActionsProvider.notifier)
        .markAsSold(listing.id);
    if (!context.mounted) return;

    ref.invalidate(listingDetailProvider(listing.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings.markedAsSoldSuccess)),
    );

    // Let the seller pick which buyer they sold to (from everyone who messaged
    // about this listing), then rate that person.
    final sellerId = ref.read(currentUserIdProvider);
    if (sellerId == null || !context.mounted) return;

    final buyers = await ref.read(chatRepositoryProvider).getListingBuyers(
          listingId: listing.id,
          sellerId: sellerId,
        );
    if (buyers.isEmpty || !context.mounted) return;

    final selected = buyers.length == 1
        ? buyers.first
        : await _pickBuyer(context, ref, buyers);
    if (selected == null || !context.mounted) return;

    await showRateDialog(
      context: context,
      ref: ref,
      listingId: listing.id,
      reviewedId: selected['id'] as String,
      reviewedName: (selected['full_name'] as String?)?.trim().isNotEmpty == true
          ? selected['full_name'] as String
          : (selected['display_name'] as String?) ?? '—',
      reviewedAvatarSeed:
          (selected['avatar_seed'] as String?) ?? (selected['id'] as String),
      subtitle: strings.rateBuyer,
    );
  }

  /// Bottom sheet to choose which buyer the listing was sold to.
  Future<Map<String, dynamic>?> _pickBuyer(
    BuildContext context,
    WidgetRef ref,
    List<Map<String, dynamic>> buyers,
  ) {
    return showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      backgroundColor: AppColors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.textMuted.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'لمن قمت بالبيع؟',
                textAlign: TextAlign.center,
                style: AppFonts.cairo(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pureWhite,
                ),
              ),
              const SizedBox(height: 16),
              for (final buyer in buyers)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Material(
                    color: AppColors.fieldCarbon,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => Navigator.pop(sheetContext, buyer),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipOval(
                              child: UserAvatar(
                                avatarSeed:
                                    (buyer['avatar_seed'] as String?) ??
                                        (buyer['id'] as String),
                                size: 42,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                (buyer['full_name'] as String?)
                                            ?.trim()
                                            .isNotEmpty ==
                                        true
                                    ? buyer['full_name'] as String
                                    : (buyer['display_name'] as String?) ??
                                        '—',
                                style: AppFonts.cairo(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ),
                            const Icon(Icons.chevron_left,
                                color: AppColors.textMuted),
                          ],
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

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final strings = ref.read(appLocalizationsProvider);
    final ok = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(strings.deleteListingTitle),
        content: Text(strings.deleteListingConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(strings.delete),
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
        SnackBar(content: Text(strings.listingDeletedSuccess)),
      );
    }
  }
}

/// WhatsApp direct-contact button shown on Pro / Premium listings.
class _WhatsAppButton extends StatelessWidget {
  const _WhatsAppButton({required this.phone});

  final String phone;

  static const _whatsAppGreen = Color(0xFF25D366);

  Future<void> _open() async {
    // Normalise: strip leading zeros / spaces, keep digits only.
    final digits = phone.replaceAll(RegExp(r'[^\d]'), '');
    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64,
      height: 56,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _open,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              color: _whatsAppGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _whatsAppGreen.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.message_rounded, size: 20, color: _whatsAppGreen),
                const SizedBox(height: 2),
                Text(
                  'واتساب',
                  style: AppFonts.cairo(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _whatsAppGreen,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: hasBorder
                ? Border.all(color: borderColor!, width: 1.2)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 21, color: foregroundColor),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.cairo(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
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
