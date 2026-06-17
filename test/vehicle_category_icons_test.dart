import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/constants/vehicle_category_icons.dart';

void main() {
  group('VehicleCategoryIcons', () {
    test('maps المركبات root and all level-1 vehicle branches', () {
      expect(
        VehicleCategoryIcons.assetForSlug('cars'),
        'assets/car-icons/car-main-category.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_automobile'),
        'assets/car-icons/Car.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_suv_pickup'),
        'assets/car-icons/4Wheel-Pickup.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_electric'),
        'assets/car-icons/electric-car.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_motorcycle'),
        'assets/car-icons/Motorcycles.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_minivan'),
        'assets/car-icons/van-or-mini-van.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_commercial'),
        'assets/car-icons/Truck.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_rental'),
        'assets/car-icons/rental-car.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_marine'),
        'assets/car-icons/Marine-Vehiacle.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_damaged'),
        'assets/car-icons/Broken-Car.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_caravan'),
        'assets/car-icons/caravan.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_classic'),
        'assets/car-icons/Classic-Car.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_aircraft'),
        'assets/car-icons/Helicopter.png',
      );
      expect(
        VehicleCategoryIcons.assetForSlug('veh_accessible'),
        'assets/car-icons/People with special needs car.png',
      );
    });

    test('returns null for unknown slugs', () {
      expect(VehicleCategoryIcons.assetForSlug('veh_atv'), isNull);
      expect(VehicleCategoryIcons.assetForSlug('real_estate'), isNull);
    });
  });
}
