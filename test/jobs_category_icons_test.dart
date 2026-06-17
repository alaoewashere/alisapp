import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/jobs_category_icons.dart';

void main() {
  group('JobsCategoryIcons', () {
    test('maps فرص العمل root and level-1 branches', () {
      expect(
        JobsCategoryIcons.assetForSlug('jobs'),
        'assets/jobs-icons/main.png',
      );
      expect(
        JobsCategoryIcons.assetForSlug('jobs_it'),
        'assets/jobs-icons/تقنيه المعلومات و البرمجه.png',
      );
      expect(
        JobsCategoryIcons.assetForSlug('jobs_freelance'),
        'assets/jobs-icons/عمل حر وعن بعد.png',
      );
    });

    test('returns null for job title slugs', () {
      expect(JobsCategoryIcons.assetForSlug('jobs_it_web_dev'), isNull);
    });
  });
}
