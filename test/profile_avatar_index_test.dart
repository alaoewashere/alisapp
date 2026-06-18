import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/preset_avatars.dart';
import 'package:Sello/shared/models/profile_model.dart';

void main() {
  group('ProfileModel avatarIndex', () {
    test('parses avatar_index from json', () {
      final profile = ProfileModel.fromJson({
        'id': 'u1',
        'full_name': 'Test',
        'avatar_index': 3,
        'created_at': '2026-01-01T00:00:00Z',
      });
      expect(profile.avatarIndex, 3);
    });

    test('clearAvatarUrl nulls avatar_url in copyWith', () {
      final profile = ProfileModel(
        id: 'u1',
        fullName: 'Test',
        avatarUrl: 'https://example.com/a.png',
        avatarIndex: 1,
        createdAt: DateTime.parse('2026-01-01T00:00:00Z'),
      );
      final cleared = profile.copyWith(clearAvatarUrl: true, avatarIndex: 4);
      expect(cleared.avatarUrl, isNull);
      expect(cleared.avatarIndex, 4);
    });
  });

  group('PresetAvatars', () {
    test('has 8 colors', () {
      expect(PresetAvatars.colors.length, 8);
    });

    test('clampIndex bounds', () {
      expect(PresetAvatars.clampIndex(-1), 0);
      expect(PresetAvatars.clampIndex(99), 7);
    });
  });
}
