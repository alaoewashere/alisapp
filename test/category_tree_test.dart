import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/category_tree.dart';
import 'package:my_app/core/utils/vehicle_brand_style.dart';
import 'package:my_app/shared/models/category_model.dart';
import 'package:my_app/shared/models/listing_model.dart';

void main() {
  test('childrenOf returns sorted subcategories', () {
    const all = [
      CategoryModel(id: 1, slug: 'real_estate', nameAr: 'العقارات', icon: '🏠'),
      CategoryModel(
        id: 2,
        slug: 're_land',
        nameAr: 'أراضي',
        icon: 'category',
        parentId: 1,
        displayOrder: 2,
      ),
      CategoryModel(
        id: 3,
        slug: 're_residential',
        nameAr: 'سكني',
        icon: '🏠',
        parentId: 1,
        displayOrder: 1,
        colorHex: '#FF9800',
      ),
    ];

    final children = childrenOf(1, all);
    expect(children.map((c) => c.slug).toList(), ['re_residential', 're_land']);
    expect(children.first.colorHex, '#FF9800');
  });

  test('isCategoryBrowseRoot includes cars, real_estate, and electronics', () {
    expect(
      isCategoryBrowseRoot(
        const CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: '🚗'),
      ),
      isTrue,
    );
    expect(
      isCategoryBrowseRoot(
        const CategoryModel(id: 2, slug: 'real_estate', nameAr: 'عقارات', icon: '🏠'),
      ),
      isTrue,
    );
    expect(
      isCategoryBrowseRoot(
        const CategoryModel(id: 3, slug: 'electronics', nameAr: 'الإلكترونيات', icon: '📱'),
      ),
      isTrue,
    );
  });

  test('subtreeListingCount sums descendant listings', () {
    const all = [
      CategoryModel(id: 10, slug: 'veh_auto_br_toyota', nameAr: 'Toyota', icon: 'brand'),
      CategoryModel(
        id: 11,
        slug: 'veh_auto_br_toyota_corolla',
        nameAr: 'Corolla',
        icon: 'model',
        parentId: 10,
      ),
      CategoryModel(
        id: 12,
        slug: 'veh_auto_br_toyota_camry',
        nameAr: 'Camry',
        icon: 'model',
        parentId: 10,
      ),
    ];
    const counts = {11: 3, 12: 2};

    expect(subtreeListingCount(10, all, counts), 5);
  });

  test('isCategoryBrowseRoot includes electronics', () {
    expect(
      isCategoryBrowseRoot(
        const CategoryModel(id: 3, slug: 'electronics', nameAr: 'الإلكترونيات', icon: '📱'),
      ),
      isTrue,
    );
  });

  test('isVehicleBrandListParent matches electronics smartphone branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 100,
          slug: 'elec_smartphones',
          nameAr: 'هواتف ذكية',
          icon: 'category',
        ),
      ),
      isTrue,
    );
  });

  test('subtitleForCategory shows custom subtitle for electronics root', () {
    const electronics = CategoryModel(
      id: 3,
      slug: 'electronics',
      nameAr: 'الإلكترونيات',
      icon: '📱',
    );

    expect(
      subtitleForCategory(electronics, const []),
      'هواتف ذكية ، أجهزة لوحية ، لابتوب وكمبيوتر ، مكيفات',
    );
  });

  test('isCategoryBrowseRoot includes buy_sell marketplace', () {
    expect(
      isCategoryBrowseRoot(
        const CategoryModel(
          id: 4,
          slug: 'buy_sell',
          nameAr: 'سوق المستعمل والجديد',
          icon: 'shopping_bag',
        ),
      ),
      isTrue,
    );
  });

  test('subtitleForCategory shows custom subtitle for buy_sell root', () {
    const buySell = CategoryModel(
      id: 4,
      slug: 'buy_sell',
      nameAr: 'سوق المستعمل والجديد',
      icon: 'shopping_bag',
    );

    expect(
      subtitleForCategory(buySell, const []),
      'موبايلات ، كمبيوتر ، ملابس ، أثاث',
    );
  });

  test('isVehicleBrandListParent matches electronics AC branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 101,
          slug: 'elec_ac',
          nameAr: 'مكيفات',
          icon: 'category',
        ),
      ),
      isTrue,
    );
  });

  test('isVehicleBrandListParent matches accessible cars branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 15,
          slug: 'veh_accessible',
          nameAr: 'سيارات ذوي الاحتياجات الخاصة',
          icon: '♿',
        ),
      ),
      isTrue,
    );
  });

  test('subtitleForCategory shows custom subtitle for accessible branch', () {
    const accessible = CategoryModel(
      id: 15,
      slug: 'veh_accessible',
      nameAr: 'سيارات ذوي الاحتياجات الخاصة',
      icon: '♿',
      parentId: 100,
    );

    expect(
      subtitleForCategory(accessible, const []),
      'Toyota , Mercedes-Benz , BMW , Kia',
    );
  });

  test('isVehicleBrandListParent matches damaged cars branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 9,
          slug: 'veh_damaged',
          nameAr: 'سيارات تالفة',
          icon: '🔧',
        ),
      ),
      isTrue,
    );
  });

  test('isVehicleBrandListParent matches caravan branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 10,
          slug: 'veh_caravan',
          nameAr: 'كرفان',
          icon: '🏕️',
        ),
      ),
      isTrue,
    );
  });

  test('vehicleBrandKeyFromSlug works for damaged car slugs', () {
    expect(vehicleBrandKeyFromSlug('veh_damaged_br_toyota'), 'toyota');
    expect(vehicleBrandKeyFromSlug('veh_damaged_br_toyota_corolla'), 'toyota');
  });

  test('subtitleForCategory shows custom subtitle for damaged branch', () {
    const damaged = CategoryModel(
      id: 9,
      slug: 'veh_damaged',
      nameAr: 'سيارات تالفة',
      icon: '🔧',
      parentId: 100,
    );

    expect(
      subtitleForCategory(damaged, const []),
      'Toyota , Mercedes-Benz , BMW , Kia',
    );
  });

  test('effectiveBrowseParentId maps rental to automobile brands', () {
    const all = [
      CategoryModel(id: 1, slug: 'veh_rental', nameAr: 'سيارات للإيجار', icon: '🔑', parentId: 100),
      CategoryModel(id: 2, slug: 'veh_automobile', nameAr: 'سيارات', icon: '🚗', parentId: 100),
      CategoryModel(id: 3, slug: 'veh_auto_br_toyota', nameAr: 'Toyota', icon: 'brand', parentId: 2),
    ];

    expect(effectiveBrowseParentId(1, all), 2);
    expect(defaultListingTypeForCategory(all[0]), ListingType.rent);
    expect(defaultListingTypeForCategory(all[1]), ListingType.sale);
  });

  test('shouldNavigateToCategoryBrowse opens rental alias without children', () {
    const rental = CategoryModel(
      id: 1,
      slug: 'veh_rental',
      nameAr: 'سيارات للإيجار',
      icon: '🔑',
      parentId: 100,
    );
    const all = [
      rental,
      CategoryModel(
        id: 2,
        slug: 'veh_automobile',
        nameAr: 'سيارات',
        icon: '🚗',
        parentId: 100,
      ),
    ];

    expect(categoryHasChildren(rental.id, all), isFalse);
    expect(shouldNavigateToCategoryBrowse(rental, all), isTrue);
  });

  test('resolveBrowseCategory finds by slug when not a root row', () {
    const all = [
      CategoryModel(
        id: 1,
        slug: 'real_estate',
        nameAr: 'العقارات',
        icon: 'home',
        parentId: 99,
      ),
    ];

    expect(
      resolveBrowseCategory('real_estate', all)?.id,
      1,
    );
  });

  test('subtitleForCategory shows custom subtitle for rental branch', () {
    const rental = CategoryModel(
      id: 1,
      slug: 'veh_rental',
      nameAr: 'سيارات للإيجار',
      icon: '🔑',
      parentId: 100,
    );
    const all = [
      rental,
      CategoryModel(
        id: 2,
        slug: 'veh_automobile',
        nameAr: 'سيارات',
        icon: '🚗',
        parentId: 100,
      ),
      CategoryModel(
        id: 10,
        slug: 'veh_auto_br_toyota',
        nameAr: 'Toyota',
        icon: 'brand',
        parentId: 2,
      ),
    ];

    expect(
      subtitleForCategory(rental, all),
      'Chevorlet , Audi , Tesla , BMW',
    );
  });

  test('isVehicleBrandListParent matches classic cars branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 11,
          slug: 'veh_classic',
          nameAr: 'سيارات كلاسيكية',
          icon: '🏆',
        ),
      ),
      isTrue,
    );
  });

  test('isVehicleBrandListParent matches aerial type branches', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 12,
          slug: 'veh_aircraft_planes',
          nameAr: 'طائرات',
          icon: 'category',
        ),
      ),
      isTrue,
    );
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 13,
          slug: 'veh_aircraft_helicopters',
          nameAr: 'مروحيات',
          icon: 'category',
        ),
      ),
      isTrue,
    );
  });

  test('subtitleForCategory shows custom subtitle for aerial branch', () {
    const aircraft = CategoryModel(
      id: 12,
      slug: 'veh_aircraft',
      nameAr: 'مركبات جوية',
      icon: '✈️',
      parentId: 100,
    );

    expect(
      subtitleForCategory(aircraft, const []),
      'طائرات ، مروحيات',
    );
  });

  test('subtitleForCategory shows custom subtitle for classic branch', () {
    const classic = CategoryModel(
      id: 11,
      slug: 'veh_classic',
      nameAr: 'سيارات كلاسيكية',
      icon: '🏆',
      parentId: 100,
    );

    expect(
      subtitleForCategory(classic, const []),
      'Mercedes-Benz , BMW , Toyota , Ford',
    );
  });

  test('subtitleForCategory shows custom subtitle for caravan branch', () {
    const caravan = CategoryModel(
      id: 10,
      slug: 'veh_caravan',
      nameAr: 'كرفان',
      icon: '🏕️',
      parentId: 100,
    );

    expect(
      subtitleForCategory(caravan, const []),
      'Coachmen , Airstream , Jayco , Winnebago',
    );
  });

  test('subtitleForCategory shows custom subtitle for motorcycle branch', () {
    const motorcycle = CategoryModel(
      id: 20,
      slug: 'veh_motorcycle',
      nameAr: 'دراجات',
      icon: '🏍️',
      parentId: 1,
    );
    const all = [
      CategoryModel(id: 1, slug: 'cars', nameAr: 'المركبات', icon: '🚗'),
      motorcycle,
      CategoryModel(
        id: 21,
        slug: 'veh_moto_br_yamaha',
        nameAr: 'Yamaha',
        icon: 'brand',
        parentId: 20,
        displayOrder: 1,
      ),
    ];

    expect(
      subtitleForCategory(motorcycle, all),
      'دراجات نارية ، دراجات هوائية ، سكوتر',
    );
  });
}
