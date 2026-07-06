import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/moderation/posting_ban_utils.dart';
import 'package:Sello/l10n/app_localizations_ar.dart';
import 'package:Sello/shared/models/profile_model.dart';

ProfileModel _profile({
  int moderationViolationCount = 0,
  DateTime? lastModerationViolationAt,
  bool isBanned = false,
  DateTime? bannedUntil,
  int banCount = 0,
}) {
  return ProfileModel(
    id: 'u1',
    fullName: 'Test',
    moderationViolationCount: moderationViolationCount,
    lastModerationViolationAt: lastModerationViolationAt,
    isBanned: isBanned,
    bannedUntil: bannedUntil,
    banCount: banCount,
    createdAt: DateTime(2024, 1, 1),
  );
}

void main() {
  final l10n = AppLocalizationsAr();

  group('effectiveModerationViolationCount', () {
    test('returns 0 when no prior violation', () {
      expect(effectiveModerationViolationCount(_profile()), 0);
    });

    test('returns stored count within 30-day window', () {
      final profile = _profile(
        moderationViolationCount: 2,
        lastModerationViolationAt: DateTime.now().subtract(const Duration(days: 5)),
      );
      expect(effectiveModerationViolationCount(profile), 2);
    });

    test('returns 0 when last violation older than 30 days', () {
      final profile = _profile(
        moderationViolationCount: 3,
        lastModerationViolationAt: DateTime.now().subtract(const Duration(days: 31)),
      );
      expect(effectiveModerationViolationCount(profile), 0);
    });
  });

  group('isUserPostingBanned', () {
    test('false when not banned', () {
      expect(isUserPostingBanned(_profile()), isFalse);
    });

    test('true for permanent ban', () {
      expect(
        isUserPostingBanned(_profile(isBanned: true, bannedUntil: null)),
        isTrue,
      );
    });

    test('true when banned_until in future', () {
      expect(
        isUserPostingBanned(
          _profile(
            isBanned: true,
            bannedUntil: DateTime.now().add(const Duration(hours: 2)),
          ),
        ),
        isTrue,
      );
    });

    test('false when banned_until expired', () {
      expect(
        isUserPostingBanned(
          _profile(
            isBanned: true,
            bannedUntil: DateTime.now().subtract(const Duration(hours: 1)),
          ),
        ),
        isFalse,
      );
    });
  });

  group('PostingBanInfo.blockedDialogBody', () {
    test('first-time ban copy mentions two days', () {
      const info = PostingBanInfo(isFirstBan: true);
      expect(
        info.blockedDialogBody(l10n),
        contains('يومين'),
      );
    });

    test('escalated ban copy mentions one month', () {
      const info = PostingBanInfo(isFirstBan: false);
      expect(
        info.blockedDialogBody(l10n),
        contains('شهر كامل'),
      );
    });

    test('permanent ban copy', () {
      const info = PostingBanInfo(isFirstBan: false, isPermanent: true);
      expect(
        info.blockedDialogBody(l10n),
        contains('بشكل دائم'),
      );
    });
  });

  group('postingBanMessage', () {
    test('permanent message', () {
      final msg = postingBanMessage(
        l10n,
        _profile(isBanned: true, bannedUntil: null),
      );
      expect(msg, contains('بشكل دائم'));
    });

    test('empty when not actively banned', () {
      expect(postingBanMessage(l10n, _profile()), '');
    });
  });
}
