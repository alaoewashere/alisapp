abstract final class RealEstateListingOptions {
  static const propertyTypes = [
    'شقة',
    'فيلا',
    'أرض',
    'محل تجاري',
    'مكتب',
    'مستودع',
    'فندق',
    'مزرعة',
  ];

  static const offerTypes = [
    'بيع',
    'إيجار',
    'إيجار يومي',
  ];

  static const roomOptions = ['1', '2', '3', '4', '5+'];

  static const bathroomOptions = ['1', '2', '3', '4+'];

  static const buildingAgeOptions = [
    'جديد',
    '1',
    '2',
    '3',
    '5',
    '10',
    '15',
    '20',
    '25+',
  ];

  static const furnishedOptions = [
    'مفروش',
    'نصف مفروش',
    'غير مفروش',
  ];

  static const deedTypeOptions = [
    'طابو',
    'وكالة',
    'عقد بيع',
  ];

  static const featureOptions = [
    'مصعد',
    'موقف سيارة',
    'حديقة',
    'بلكون',
    'كاميرات',
    'جنريتر',
    'خزان ماء',
    'مسبح',
  ];

  static final floorOptions = List.generate(30, (i) => '${i + 1}');
}
