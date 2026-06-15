abstract final class AnimalListingOptions {
  static const genders = [
    'ذكر',
    'أنثى',
  ];

  static const colors = [
    'أسود',
    'أبيض',
    'بني',
    'رمادي',
    'ذهبي',
    'مرقط',
    'ثلاثي الألوان',
    'أخرى',
  ];

  static const branchSlugToType = {
    'pets_dogs': 'كلب',
    'pets_cats': 'قطة',
    'pets_birds': 'طائر',
    'pets_fish': 'سمك',
    'pets_farm': 'مزرعة',
    'pets_reptiles': 'زواحف',
    'pets_rabbits': 'أرنب',
    'pets_horses': 'خيل',
  };

  static bool showTrainedToggle(String? animalType) {
    return animalType == 'كلب' || animalType == 'خيل';
  }
}
