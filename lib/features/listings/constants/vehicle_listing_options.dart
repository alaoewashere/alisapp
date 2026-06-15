import 'package:flutter/material.dart';

abstract final class VehicleListingOptions {
  static const cylinderOptions = [
    '3',
    '4',
    '6',
    '8',
    '10',
    '12',
    'كهربائي',
  ];

  static const paintPartOptions = [
    'نظيف',
    'مصبوغ جزئي',
    'مصبوغ كلي',
    'حوادث',
  ];

  static const fuelOptions = [
    'بنزين',
    'ديزل',
    'هايبرد',
    'كهربائي',
    'غاز',
  ];

  static const importCountryOptions = [
    'أمريكي',
    'كوري',
    'خليجي',
    'أوروبي',
    'ياباني',
    'صيني',
    'عراقي',
  ];

  static const plateOptions = [
    'بغداد',
    'البصرة',
    'أربيل',
    'السليمانية',
    'دهوك',
    'الموصل',
    'كركوك',
    'النجف',
    'كربلاء',
    'الحلة',
    'الديوانية',
    'العمارة',
    'الناصرية',
    'الكوت',
    'الرمادي',
    'تكريت',
    'سامراء',
    'مؤقتة',
    'بدون لوحة',
  ];

  static const transmissionOptions = [
    'أوتوماتيك',
    'يدوي',
    'CVT',
  ];

  static const seatNumberOptions = [
    '2',
    '4',
    '5',
    '7',
    '8',
    '9+',
  ];

  static const seatMaterialOptions = [
    'جلد',
    'قماش',
    'مزيج',
  ];

  static const vehicleSpecGroups = [
    VehicleSpecGroup(
      title: 'الأمان',
      specs: [
        'ABS',
        '8 وسائد هوائية',
        'مساعد الفرملة الطارئة',
        'مراقب النقطة العمياء',
        'التعرف على إشارات المرور',
        'تحكم في الجر',
        'تثبيت تلقائي',
        'مثبت سرعة تكيفي',
        'مستشعرات ضغط الإطارات',
        'تنبيه انتباه السائق',
        'قفل أطفال',
        'مساعد الازدحام',
        'تنبيه حركة المرور الخلفية',
        'قفل مركزي',
      ],
    ),
    VehicleSpecGroup(
      title: 'الراحة',
      specs: [
        'تحكم تلقائي بالحرارة',
        'تدفئة المقاعد',
        'مقاعد مساج',
        'فتحة سقف',
        'دخول بدون مفتاح',
        'مسند ذراع',
        'مرايا كهربائية',
        'مرايا جانبية مدفأة',
        'نوافذ كهربائية',
        'شاشة',
        'نظام ستارت ستوب',
        'عرض رأسي HUD',
        'دفة مدفأة',
        'كوكبيت رقمي',
        'إضاءة محيطية',
        'Apple CarPlay',
        'Android Auto',
        'تشغيل عن بعد',
        'شاحن لاسلكي',
        'ركن عن بعد',
        'وضع القيادة',
        'زر تشغيل',
        'توجيه كهربائي',
        'نظام صوتي Harman Kardon',
        'هيل هولدر',
      ],
    ),
    VehicleSpecGroup(
      title: 'الخارج',
      specs: [
        'كاميرا خلفية',
        'كاميرا 360',
        'رادار',
        'إضاءة LED',
        'إضاءة ليزر',
        'ضباب أمامي',
        'إضاءة عالية تلقائية',
        'إضاءة تكيفية',
      ],
    ),
  ];

  static List<String> get vehicleSpecOptions => [
        for (final group in vehicleSpecGroups) ...group.specs,
      ];
}

class VehicleSpecGroup {
  const VehicleSpecGroup({required this.title, required this.specs});

  final String title;
  final List<String> specs;
}

class CarColorOption {
  const CarColorOption(this.labelAr, this.color, {this.isOther = false});

  final String labelAr;
  final Color color;
  final bool isOther;
}

abstract final class VehicleCarColors {
  static const otherLabel = 'أخرى';
  static const legacyOtherLabel = 'آخر';

  static bool isOtherLabel(String? label) =>
      label == otherLabel || label == legacyOtherLabel;

  static const options = [
    CarColorOption('أبيض', Color(0xFFF5F5F5)),
    CarColorOption('أسود', Color(0xFF212121)),
    CarColorOption('رمادي', Color(0xFF757575)),
    CarColorOption('فضي', Color(0xFFB0BEC5)),
    CarColorOption('أحمر', Color(0xFFD32F2F)),
    CarColorOption('أزرق', Color(0xFF1976D2)),
    CarColorOption('أخضر', Color(0xFF388E3C)),
    CarColorOption('بيج', Color(0xFFD7CCC8)),
    CarColorOption('بني', Color(0xFF795548)),
    CarColorOption('برتقالي', Color(0xFFF57C00)),
    CarColorOption('بنفسجي', Color(0xFF7B1FA2)),
    CarColorOption('ذهبي', Color(0xFFFFB300)),
    CarColorOption(otherLabel, Color(0xFF9E9E9E), isOther: true),
  ];
}
