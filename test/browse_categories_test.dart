import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/browse_categories.dart';
import 'package:Sello/l10n/app_localizations.dart';
import 'package:Sello/shared/models/category_model.dart';

void main() {
  test('buildBrowseCategoryItems maps slug to id and subcategory subtitle', () {
    const all = [
      CategoryModel(
        id: 1,
        slug: 'real_estate',
        nameAr: 'عقارات',
        icon: 'home',
      ),
      CategoryModel(
        id: 10,
        slug: 'apartments',
        nameAr: 'شقق',
        icon: 'apartment',
        parentId: 1,
      ),
      CategoryModel(
        id: 11,
        slug: 'villas',
        nameAr: 'فلل',
        icon: 'villa',
        parentId: 1,
      ),
    ];

    final strings = lookupAppLocalizations(const Locale('ar'));
    final items = buildBrowseCategoryItems(all, 'ar', strings);
    final realEstate = items.firstWhere((i) => i.style.slug == 'real_estate');

    expect(realEstate.categoryId, 1);
    expect(realEstate.subtitle, 'شقق ، فلل');
  });

  test('buildBrowseCategoryItems uses fallback subtitle when no children', () {
    const all = [
      CategoryModel(
        id: 2,
        slug: 'cars',
        nameAr: 'سيارات',
        icon: 'car',
      ),
    ];

    final strings = lookupAppLocalizations(const Locale('ar'));
    final items = buildBrowseCategoryItems(all, 'ar', strings);
    final cars = items.firstWhere((i) => i.style.slug == 'cars');

    expect(cars.categoryId, 2);
    expect(cars.subtitle, strings.categorySubtitleVehicles);
  });

  test('buildBrowseCategoryItems sorts by display_order from DB', () {
    const all = [
      CategoryModel(
        id: 1,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'home',
        displayOrder: 1,
      ),
      CategoryModel(
        id: 2,
        slug: 'cars',
        nameAr: 'المركبات',
        icon: 'car',
        displayOrder: 2,
      ),
      CategoryModel(
        id: 3,
        slug: 'electronics',
        nameAr: 'الإلكترونيات',
        icon: 'devices',
        displayOrder: 3,
      ),
    ];

    final strings = lookupAppLocalizations(const Locale('ar'));
    final slugs =
        buildBrowseCategoryItems(all, 'ar', strings).map((i) => i.style.slug).toList();
    expect(slugs.indexOf('real_estate'), lessThan(slugs.indexOf('cars')));
    expect(slugs.indexOf('cars'), lessThan(slugs.indexOf('electronics')));
  });
}
