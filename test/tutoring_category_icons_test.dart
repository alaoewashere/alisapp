import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/tutoring_category_icons.dart';

void main() {
  group('TutoringCategoryIcons', () {
    test('maps دروس خصوصية root and level-1 branches', () {
      expect(
        TutoringCategoryIcons.assetForSlug('tutoring'),
        'assets/special-lesson/main.png',
      );
      expect(
        TutoringCategoryIcons.assetForSlug('tutor_school'),
        'assets/special-lesson/دروس المدرسه.png',
      );
      expect(
        TutoringCategoryIcons.assetForSlug('tutor_university'),
        'assets/special-lesson/دروس جامعيه.png',
      );
      expect(
        TutoringCategoryIcons.assetForSlug('tutor_languages'),
        'assets/special-lesson/تعليم اللغات.png',
      );
      expect(
        TutoringCategoryIcons.assetForSlug('tutor_quran'),
        'assets/special-lesson/القران والعلوم الدينيه.png',
      );
      expect(
        TutoringCategoryIcons.assetForSlug('tutor_professional'),
        'assets/special-lesson/مهارات مهنيه وتقنيه.png',
      );
    });

    test('returns null for subject slugs', () {
      expect(TutoringCategoryIcons.assetForSlug('tutor_school_math'), isNull);
    });
  });
}
