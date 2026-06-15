abstract final class HomeServiceListingOptions {
  static const genders = [
    'ذكر',
    'أنثى',
    'أخرى',
  ];

  static const nationalities = [
    'عراقي',
    'أجنبي',
    'أخرى',
  ];

  static const availabilityOptions = [
    'صباحي',
    'مسائي',
    'يومي كامل',
    'مقيم',
  ];

  static const languages = [
    'عربي',
    'كردي',
    'إنجليزي',
    'تركي',
    'فارسي',
  ];

  static const branchSlugToService = {
    'home_cleaning': 'تنظيف',
    'home_cooking': 'طبخ',
    'home_childcare': 'رعاية أطفال',
    'home_eldercare': 'رعاية مسنين',
    'home_driver': 'سائق',
    'home_gardening': 'حدائق',
    'home_maintenance': 'صيانة منزلية',
    'home_moving': 'نقل أثاث',
    'home_security': 'حراسة',
    'home_laundry': 'غسيل وكي',
  };
}
