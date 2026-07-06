import '../../l10n/app_localizations.dart';
import '../../shared/models/profile_model.dart';

/// Rolling 30-day violation window — mirrors [effective_moderation_violation_count].
int effectiveModerationViolationCount(ProfileModel profile) {
  final last = profile.lastModerationViolationAt;
  if (last == null) return 0;
  if (DateTime.now().difference(last).inDays > 30) return 0;
  return profile.moderationViolationCount;
}

/// Whether the user is currently banned from chat posting and listing create/edit.
bool isUserPostingBanned(ProfileModel profile) {
  if (!profile.isBanned) return false;
  final until = profile.bannedUntil;
  if (until == null) return true;
  return until.isAfter(DateTime.now());
}

/// Ban info returned from [record_moderation_block] or parsed from profile.
class PostingBanInfo {
  const PostingBanInfo({
    required this.isFirstBan,
    this.bannedUntil,
    this.isPermanent = false,
    this.message,
  });

  final bool isFirstBan;
  final DateTime? bannedUntil;
  final bool isPermanent;
  final String? message;

  factory PostingBanInfo.fromJson(Map<String, dynamic> json) {
    final untilRaw = json['banned_until'] as String?;
    return PostingBanInfo(
      isFirstBan: json['is_first_ban'] as bool? ?? false,
      bannedUntil:
          untilRaw != null ? DateTime.tryParse(untilRaw)?.toLocal() : null,
      isPermanent: json['is_permanent'] as bool? ?? false,
      message: json['message'] as String?,
    );
  }

  factory PostingBanInfo.fromProfile(
    ProfileModel profile, {
    required AppLocalizations strings,
  }) {
    final permanent = profile.isBanned && profile.bannedUntil == null;
    return PostingBanInfo(
      isFirstBan: profile.banCount <= 1,
      bannedUntil: profile.bannedUntil,
      isPermanent: permanent,
      message: postingBanMessage(strings, profile),
    );
  }

  String blockedDialogBody(AppLocalizations strings) {
    if (isPermanent) {
      return strings.postingBanPermanentReason;
    }
    if (isFirstBan) {
      return strings.postingBanFirstReason;
    }
    return strings.postingBanRepeatReason;
  }
}

String postingBanMessage(AppLocalizations strings, ProfileModel profile) {
  if (!isUserPostingBanned(profile)) return '';

  if (profile.bannedUntil == null) {
    return strings.postingBanPermanent;
  }

  final until = profile.bannedUntil!.toLocal();
  final formatted =
      '${until.year}-${until.month.toString().padLeft(2, '0')}-${until.day.toString().padLeft(2, '0')} '
      '${until.hour.toString().padLeft(2, '0')}:${until.minute.toString().padLeft(2, '0')}';
  return strings.postingBanUntil(formatted);
}

bool isUserPostingBannedError(Object error) {
  final text = error.toString();
  return text.contains('user_posting_banned');
}

String? extractPostingBanMessage(Object error) {
  final text = error.toString();
  const prefix = 'user_posting_banned:';
  final idx = text.indexOf(prefix);
  if (idx < 0) return null;
  return text.substring(idx + prefix.length).trim();
}
