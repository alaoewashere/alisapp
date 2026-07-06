import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/shared/models/category_model.dart';

void main() {
  const category = CategoryModel(
    id: 1,
    slug: 'real_estate',
    nameAr: 'العقارات',
    nameEn: 'Real Estate',
    nameKu: 'خانوووبەرە',
    nameTr: 'Emlak',
    icon: 'home',
  );

  test('displayName returns locale-specific column with Arabic fallback', () {
    expect(category.displayName('ar'), 'العقارات');
    expect(category.displayName('en'), 'Real Estate');
    expect(category.displayName('ku'), 'خانوووبەرە');
    expect(category.displayName('tr'), 'Emlak');
  });

  test('displayName ignores Arabic values in name_en for English locale', () {
    const wrongCopy = CategoryModel(
      id: 3,
      slug: 'tutor_school_math',
      nameAr: 'الرياضيات',
      nameEn: 'الرياضيات',
      icon: 'model',
    );
    expect(wrongCopy.displayName('en'), 'tutor school math');
  });

  test('displayDescription returns locale-specific column', () {
    const withDesc = CategoryModel(
      id: 4,
      slug: 'tutor_school',
      nameAr: 'دروس المدرسة',
      descriptionAr: 'الرياضيات ، الفيزياء',
      descriptionEn: 'Mathematics, Physics',
      descriptionTr: 'Matematik, Fizik',
      icon: 'category',
    );
    expect(withDesc.displayDescription('en'), 'Mathematics, Physics');
    expect(withDesc.displayDescription('tr'), 'Matematik, Fizik');
    expect(withDesc.displayDescription('ar'), 'الرياضيات ، الفيزياء');
  });

  test('displayDescription does not fall back to Arabic for English', () {
    const arabicOnly = CategoryModel(
      id: 5,
      slug: 'home_cleaning',
      nameAr: 'تنظيف المنازل',
      descriptionAr: 'تنظيف يومي ، تنظيف أسبوعي',
      icon: 'category',
    );
    expect(arabicOnly.displayDescription('en'), '');
    expect(arabicOnly.displayDescription('ar'), 'تنظيف يومي ، تنظيف أسبوعي');
  });
}
