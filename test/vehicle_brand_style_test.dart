import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/category_tree.dart';
import 'package:my_app/core/utils/vehicle_brand_style.dart';
import 'package:my_app/shared/models/category_model.dart';

void main() {
  test('isVehicleBrandListParent matches automobile branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 1,
          slug: 'veh_automobile',
          nameAr: 'سيارات',
          icon: '🚗',
        ),
      ),
      isTrue,
    );
  });

  test('vehicleBrandKeyFromSlug extracts brand key', () {
    expect(vehicleBrandKeyFromSlug('veh_auto_br_toyota'), 'toyota');
    expect(vehicleBrandKeyFromSlug('veh_auto_br_toyota_corolla'), 'toyota');
  });

  test('vehicleBrandInitial uses first letter', () {
    expect(
      vehicleBrandInitial(
        const CategoryModel(
          id: 1,
          slug: 'veh_auto_br_bmw',
          nameAr: 'BMW',
          icon: 'brand',
        ),
      ),
      'B',
    );
  });

  test('isSvgLogoUrl detects svg extension', () {
    expect(
      isSvgLogoUrl(
        'https://x.supabase.co/storage/v1/object/public/brand-logos/toyota.svg',
      ),
      isTrue,
    );
    expect(
      isSvgLogoUrl(
        'https://x.supabase.co/storage/v1/object/public/brand-logos/toyota.png',
      ),
      isFalse,
    );
    expect(isSvgLogoUrl(null), isFalse);
  });

  test('vehicleBrandLogoUrl prefers stored logoUrl', () {
    expect(
      vehicleBrandLogoUrl(
        const CategoryModel(
          id: 1,
          slug: 'veh_auto_br_toyota',
          nameAr: 'Toyota',
          icon: 'brand',
          logoUrl: 'https://example.com/toyota.png',
        ),
      ),
      'https://example.com/toyota.png',
    );
  });

  test('vehicleBrandLogoUrl falls back to carlogos pattern', () {
    expect(
      vehicleBrandLogoUrl(
        const CategoryModel(
          id: 1,
          slug: 'veh_auto_br_toyota',
          nameAr: 'Toyota',
          icon: 'brand',
        ),
      ),
      'https://www.carlogos.org/car-logos/toyota-logo.png',
    );
  });

  test('vehicleBrandKeyFromSlug extracts motorcycle brand key', () {
    expect(vehicleBrandKeyFromSlug('veh_moto_br_yamaha'), 'yamaha');
    expect(vehicleBrandKeyFromSlug('veh_moto_br_yamaha_yzf_r1'), 'yamaha');
  });

  test('vehicleBrandLogoUrl falls back to motorcycle-logos pattern', () {
    expect(
      vehicleBrandLogoUrl(
        const CategoryModel(
          id: 1,
          slug: 'veh_moto_br_yamaha',
          nameAr: 'Yamaha',
          icon: 'brand',
        ),
      ),
      'https://www.carlogos.org/motorcycle-logos/yamaha-logo.png',
    );
    expect(
      vehicleBrandLogoUrl(
        const CategoryModel(
          id: 2,
          slug: 'veh_moto_br_bmw',
          nameAr: 'BMW',
          icon: 'brand',
        ),
      ),
      'https://www.carlogos.org/motorcycle-logos/bmw-motorrad-logo.png',
    );
  });

  test('isVehicleBrandListParent matches motorcycle branch', () {
    expect(
      isVehicleBrandListParent(
        const CategoryModel(
          id: 20,
          slug: 'veh_motorcycle',
          nameAr: 'دراجات',
          icon: '🏍️',
        ),
      ),
      isTrue,
    );
  });
}
