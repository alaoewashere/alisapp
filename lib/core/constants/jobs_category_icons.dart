/// Local PNG icons for فرص العمل and subcategories (`assets/jobs-icons/`).
abstract final class JobsCategoryIcons {
  static const basePath = 'assets/jobs-icons';

  static const Map<String, String> bySlug = {
    'jobs': '$basePath/main.png',
    'jobs_it': '$basePath/تقنيه المعلومات و البرمجه.png',
    'jobs_engineering': '$basePath/الهندسه و البناء.png',
    'jobs_medical': '$basePath/الطب والصحه.png',
    'jobs_business': '$basePath/الاعمال واداره المال.png',
    'jobs_education': '$basePath/التعليم والتدريب.png',
    'jobs_oil_energy': '$basePath/النفط و الطاقه.png',
    'jobs_media': '$basePath/الاعلام والتصميم والفنون.png',
    'jobs_hospitality': '$basePath/الضيافه والسياحه والمطاعم.png',
    'jobs_trades': '$basePath/الحرف والمهن اليدويه.png',
    'jobs_freelance': '$basePath/عمل حر وعن بعد.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
