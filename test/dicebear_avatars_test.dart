import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/dicebear_avatars.dart';

void main() {
  test('avatarUrl builds DiceBear glyphs URL', () {
    final url = DiceBearAvatars.urlFor('Felix');
    expect(url, contains('api.dicebear.com/10.x/glyphs/svg'));
    expect(url, contains('seed=Felix'));
    expect(url, isNot(contains('backgroundColor')));
  });

  test('resolveSeed falls back to Felix', () {
    expect(DiceBearAvatars.resolveSeed(null), 'Felix');
    expect(DiceBearAvatars.resolveSeed(''), 'Felix');
    expect(DiceBearAvatars.resolveSeed('Mia'), 'Mia');
  });

  test('seeds list has 30 entries', () {
    expect(DiceBearAvatars.seeds.length, 30);
  });
}
