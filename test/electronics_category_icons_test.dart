import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/constants/electronics_category_icons.dart';

void main() {
  group('ElectronicsCategoryIcons', () {
    test('maps الإلكترونيات root and all level-1 branches', () {
      expect(
        ElectronicsCategoryIcons.assetForSlug('electronics'),
        'assets/electronics-icons/Main.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_smartphones'),
        'assets/electronics-icons/هواتف ذكيه.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_tablets'),
        'assets/electronics-icons/اجهزه لوحيه.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_laptops'),
        'assets/electronics-icons/لابتوب وكمبيوتر.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_displays'),
        'assets/electronics-icons/شاشات وتلفزيونات.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_cameras'),
        'assets/electronics-icons/كاميرات.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_audio'),
        'assets/electronics-icons/سماعات وصوتيات.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_gaming'),
        'assets/electronics-icons/العاب فيديو.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_wearables'),
        'assets/electronics-icons/ساعات ذكيه واكسسوار.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_printers'),
        'assets/electronics-icons/طابعات وملحقات.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_networking'),
        'assets/electronics-icons/شبكات وراوتر.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_appliances'),
        'assets/electronics-icons/احهزه المنزل الذكيه.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_ac'),
        'assets/electronics-icons/مكيفات.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_desktops'),
        'assets/electronics-icons/كمبيوتر مكتبي.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_drones'),
        'assets/electronics-icons/drones.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_projectors'),
        'assets/electronics-icons/بروجكتور وشاشه عرض.png',
      );
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_medical'),
        'assets/electronics-icons/اجهزه طبيه منزليه .png',
      );
    });

    test('returns null for brand slugs', () {
      expect(
        ElectronicsCategoryIcons.assetForSlug('elec_smartphones_br_apple'),
        isNull,
      );
    });
  });
}
