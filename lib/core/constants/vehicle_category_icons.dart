/// Local PNG icons for المركبات and its subcategories (`assets/car-icons/`).
abstract final class VehicleCategoryIcons {
  static const basePath = 'assets/car-icons';

  static const Map<String, String> bySlug = {
    'cars': '$basePath/car-main-category.png',
    'veh_automobile': '$basePath/Car.png',
    'veh_suv_pickup': '$basePath/4Wheel-Pickup.png',
    'veh_electric': '$basePath/electric-car.png',
    'veh_motorcycle': '$basePath/Motorcycles.png',
    'veh_minivan': '$basePath/van-or-mini-van.png',
    'veh_commercial': '$basePath/Truck.png',
    'veh_rental': '$basePath/rental-car.png',
    'veh_marine': '$basePath/Marine-Vehiacle.png',
    'veh_damaged': '$basePath/Broken-Car.png',
    'veh_caravan': '$basePath/caravan.png',
    'veh_classic': '$basePath/Classic-Car.png',
    'veh_aircraft': '$basePath/Helicopter.png',
    'veh_accessible':
        '$basePath/People with special needs car.png',
  };

  static String? assetForSlug(String slug) => bySlug[slug];

  static bool hasAsset(String slug) => bySlug.containsKey(slug);
}
