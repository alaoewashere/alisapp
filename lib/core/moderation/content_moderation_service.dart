import '../utils/arabic_text_normalizer.dart';
import 'moderation_result.dart';

/// Shared client-side profanity filter — mirrors server `apply_content_moderation`.
class ContentModerationService {
  const ContentModerationService();

  /// [violationCount] is the user's persisted count before this submission.
  ModerationResult moderate({
    required String text,
    required String userId,
    required int violationCount,
    required List<String> blockedNormalizedWords,
  }) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || userId.isEmpty) {
      return ModerationResult.allowed(trimmed);
    }

    final hadViolation = containsBlockedWord(
      trimmed,
      blockedNormalizedWords,
    );

    if (!hadViolation) {
      return ModerationResult.allowed(trimmed);
    }

    if (violationCount > 0) {
      return ModerationResult(
        censoredText: trimmed,
        hadViolation: true,
        shouldBlock: true,
      );
    }

    return ModerationResult(
      censoredText: censorBlockedWords(trimmed, blockedNormalizedWords),
      hadViolation: true,
      shouldBlock: false,
    );
  }

  /// Moderates multiple fields; block wins, else returns per-field censored map.
  ModerationBatchResult moderateFields({
    required Map<String, String> fields,
    required String userId,
    required int violationCount,
    required List<String> blockedNormalizedWords,
  }) {
    var shouldBlock = false;
    var hadViolation = false;
    final censored = <String, String>{};

    for (final entry in fields.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) {
        censored[entry.key] = value;
        continue;
      }
      final result = moderate(
        text: value,
        userId: userId,
        violationCount: violationCount,
        blockedNormalizedWords: blockedNormalizedWords,
      );
      if (result.shouldBlock) shouldBlock = true;
      if (result.hadViolation) hadViolation = true;
      censored[entry.key] = result.censoredText;
    }

    return ModerationBatchResult(
      censoredFields: censored,
      hadViolation: hadViolation,
      shouldBlock: shouldBlock,
    );
  }
}

class ModerationBatchResult {
  const ModerationBatchResult({
    required this.censoredFields,
    required this.hadViolation,
    required this.shouldBlock,
  });

  final Map<String, String> censoredFields;
  final bool hadViolation;
  final bool shouldBlock;
}
