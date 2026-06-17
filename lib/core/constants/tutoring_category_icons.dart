/// Local PNG icons for دروس خصوصية and subcategories (`assets/special-lesson/`).
abstract final class TutoringCategoryIcons {
  static const basePath = 'assets/special-lesson';

  static const Map<String, String> bySlug = {
    'tutoring': '$basePath/main.png',
    'tutor_school': '$basePath/دروس المدرسه.png',
    'tutor_university': '$basePath/دروس جامعيه.png',
    'tutor_languages': '$basePath/تعليم اللغات.png',
    'tutor_quran': '$basePath/القران والعلوم الدينيه.png',
    'tutor_professional': '$basePath/مهارات مهنيه وتقنيه.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
