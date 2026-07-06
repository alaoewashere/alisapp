import 'package:flutter/material.dart';
import 'package:Sello/core/theme/app_fonts.dart';

import '../constants/app_colors.dart';
import '../l10n/l10n_provider.dart';
import 'posting_ban_utils.dart';

/// Which moderation warning to present.
enum ModerationDialogVariant {
  /// First violation — content censored but submission allowed.
  censored,

  /// Repeat violation — submission blocked (+ auto posting ban).
  blocked,

  /// User already banned from posting/chat.
  postingBan,
}

/// Result of a listing publish/save after moderation checks.
class PublishListingOutcome {
  const PublishListingOutcome({
    this.listingId,
    this.moderationDialog,
    this.banInfo,
    this.postingBanMessage,
  });

  final String? listingId;
  final ModerationDialogVariant? moderationDialog;
  final PostingBanInfo? banInfo;
  final String? postingBanMessage;
}

class EditListingSaveOutcome {
  const EditListingSaveOutcome({
    required this.success,
    this.moderationDialog,
    this.banInfo,
    this.postingBanMessage,
  });

  final bool success;
  final ModerationDialogVariant? moderationDialog;
  final PostingBanInfo? banInfo;
  final String? postingBanMessage;
}

/// Blocking modal for profanity / moderation warnings.
Future<void> showModerationWarningDialog(
  BuildContext context, {
  required ModerationDialogVariant variant,
  PostingBanInfo? banInfo,
  String? postingBanMessage,
}) {
  return showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: false,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (dialogContext) => ModerationWarningDialog(
      variant: variant,
      banInfo: banInfo,
      postingBanMessage: postingBanMessage,
    ),
  );
}

class ModerationWarningDialog extends StatelessWidget {
  const ModerationWarningDialog({
    super.key,
    required this.variant,
    this.banInfo,
    this.postingBanMessage,
  });

  final ModerationDialogVariant variant;
  final PostingBanInfo? banInfo;
  final String? postingBanMessage;

  bool get _isBlocked => variant == ModerationDialogVariant.blocked;
  bool get _isPostingBan => variant == ModerationDialogVariant.postingBan;

  Color get _iconColor {
    if (_isPostingBan || _isBlocked) return AppColors.rejected;
    return AppColors.pending;
  }

  IconData get _icon {
    if (_isPostingBan || _isBlocked) return Icons.block_rounded;
    return Icons.warning_amber_rounded;
  }

  String _title(BuildContext context) {
    final strings = context.l10n;
    if (_isPostingBan) return strings.moderationYouAreBanned;
    if (_isBlocked) return strings.moderationBannedTitle;
    return strings.moderationWarningTitle;
  }

  String _body(BuildContext context) {
    final strings = context.l10n;
    if (_isPostingBan) {
      return postingBanMessage?.trim().isNotEmpty == true
          ? postingBanMessage!.trim()
          : strings.moderationPostingBanDefault;
    }
    if (_isBlocked) {
      return banInfo?.blockedDialogBody(strings) ??
          strings.moderationBlockedBody;
    }
    return strings.moderationCensoredBody;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: AppColors.fieldCarbon,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.glassBorder),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _iconColor.withValues(alpha: 0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(_icon, size: 36, color: _iconColor),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    _title(context),
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _body(context),
                    textAlign: TextAlign.center,
                    style: AppFonts.cairo(
                      fontSize: 15,
                      height: 1.55,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        context.l10n.understood,
                        style: AppFonts.cairo(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> showModerationCensoredWarning(BuildContext context) =>
    showModerationWarningDialog(
      context,
      variant: ModerationDialogVariant.censored,
    );

Future<void> showModerationBlockedWarning(
  BuildContext context, {
  PostingBanInfo? banInfo,
}) =>
    showModerationWarningDialog(
      context,
      variant: ModerationDialogVariant.blocked,
      banInfo: banInfo,
    );

Future<void> showPostingBanDialog(
  BuildContext context, {
  required String message,
}) =>
    showModerationWarningDialog(
      context,
      variant: ModerationDialogVariant.postingBan,
      postingBanMessage: message,
    );
