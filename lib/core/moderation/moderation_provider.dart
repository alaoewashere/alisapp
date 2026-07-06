import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/l10n_provider.dart';
import '../supabase/supabase_client.dart';
import '../../features/profile/data/profile_repository.dart';
import 'blocked_words_repository.dart';
import 'content_moderation_service.dart';
import 'moderation_repository.dart';
import 'moderation_result.dart';
import 'moderation_warning_dialog.dart';
import 'posting_ban_utils.dart';

export 'moderation_repository.dart' show moderationRepositoryProvider;
export 'moderation_warning_dialog.dart' show
    EditListingSaveOutcome,
    ModerationDialogVariant,
    PublishListingOutcome,
    showModerationBlockedWarning,
    showModerationCensoredWarning,
    showModerationWarningDialog,
    showPostingBanDialog;
export 'posting_ban_utils.dart'
    show
        PostingBanInfo,
        effectiveModerationViolationCount,
        extractPostingBanMessage,
        isUserPostingBanned,
        isUserPostingBannedError,
        postingBanMessage;

final contentModerationServiceProvider =
    Provider<ContentModerationService>((ref) {
  return const ContentModerationService();
});

final blockedWordsProvider = FutureProvider<List<String>>((ref) async {
  return ref.watch(blockedWordsRepositoryProvider).fetchActiveNormalizedForms();
});

final moderationViolationCountProvider = Provider<int>((ref) {
  final profile = ref.watch(currentProfileProvider).value;
  if (profile == null) return 0;
  return effectiveModerationViolationCount(profile);
});

bool isModerationBlockedError(Object error) {
  if (error is PostgrestException) {
    final msg = error.message.toLowerCase();
    return msg.contains('content_moderation_blocked') ||
        msg.contains('p0001');
  }
  return error.toString().contains('content_moderation_blocked');
}

/// Returns true when the user is banned and the gate dialog was shown.
Future<bool> checkPostingBanGate(
  WidgetRef ref,
  BuildContext context,
) async {
  final profile = ref.read(currentProfileProvider).value;
  if (profile == null || !isUserPostingBanned(profile)) return false;

  await showPostingBanDialog(
    context,
    message: postingBanMessage(ref.read(appLocalizationsProvider), profile),
  );
  return true;
}

/// After a server-side block or ban, refresh profile violation/ban state.
extension ModerationStateInvalidation on Ref {
  void invalidateModerationState() {
    invalidate(currentProfileProvider);
    invalidate(blockedWordsProvider);
  }
}

extension ModerationStateInvalidationWidget on WidgetRef {
  void invalidateModerationState() {
    invalidate(currentProfileProvider);
    invalidate(blockedWordsProvider);
  }
}

/// Server-side block + auto-ban when client rejects before insert.
Future<PostingBanInfo?> recordClientModerationBlock(
  ModerationRepository repo, {
  required String source,
  String? fieldName,
  String? excerpt,
}) async {
  return repo.recordModerationBlock(
    source: source,
    fieldName: fieldName,
    excerpt: excerpt,
  );
}

Future<void> handlePostingBanOrBlockError(
  WidgetRef ref,
  BuildContext context,
  Object error,
) async {
  if (isUserPostingBannedError(error)) {
    final msg = extractPostingBanMessage(error);
    if (msg != null && msg.isNotEmpty) {
      await showPostingBanDialog(context, message: msg);
      return;
    }
    final profile = ref.read(currentProfileProvider).value;
    if (profile != null) {
      await showPostingBanDialog(
        context,
        message: postingBanMessage(ref.read(appLocalizationsProvider), profile),
      );
    }
    return;
  }
  if (isModerationBlockedError(error)) {
    await showModerationBlockedWarning(context);
    ref.invalidateModerationState();
  }
}

/// Client-side moderation gate before submit.
Future<ModerationResult> moderateUserText(
  WidgetRef ref, {
  required String text,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) return ModerationResult.allowed(text);

  final words = await ref.read(blockedWordsProvider.future);
  final violationCount = ref.read(moderationViolationCountProvider);

  return ref.read(contentModerationServiceProvider).moderate(
        text: text,
        userId: userId,
        violationCount: violationCount,
        blockedNormalizedWords: words,
      );
}

Future<ModerationBatchResult> moderateUserFields(
  WidgetRef ref, {
  required Map<String, String> fields,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    return ModerationBatchResult(
      censoredFields: fields,
      hadViolation: false,
      shouldBlock: false,
    );
  }

  final words = await ref.read(blockedWordsProvider.future);
  final violationCount = ref.read(moderationViolationCountProvider);

  return ref.read(contentModerationServiceProvider).moderateFields(
        fields: fields,
        userId: userId,
        violationCount: violationCount,
        blockedNormalizedWords: words,
      );
}

Future<ModerationBatchResult> moderateFieldsForUser(
  Ref ref, {
  required Map<String, String> fields,
}) async {
  final userId = ref.read(currentUserIdProvider);
  if (userId == null) {
    return ModerationBatchResult(
      censoredFields: fields,
      hadViolation: false,
      shouldBlock: false,
    );
  }

  final words =
      await ref.read(blockedWordsRepositoryProvider).fetchActiveNormalizedForms();
  final profile = ref.read(currentProfileProvider).value;
  final violationCount = profile == null
      ? 0
      : effectiveModerationViolationCount(profile);

  return ref.read(contentModerationServiceProvider).moderateFields(
        fields: fields,
        userId: userId,
        violationCount: violationCount,
        blockedNormalizedWords: words,
      );
}