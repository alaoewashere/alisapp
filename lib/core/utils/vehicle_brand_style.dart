import 'package:flutter/material.dart';

import '../../shared/models/category_model.dart';

/// Brand accent colors keyed by slug fragment (e.g. toyota from veh_auto_br_toyota).
const _brandColors = <String, Color>{
  'toyota': Color(0xFFEB0A1E),
  'mercedes_benz': Color(0xFF242424),
  'bmw': Color(0xFF0066B1),
  'kia': Color(0xFF05141F),
  'hyundai': Color(0xFF002C5F),
  'volkswagen': Color(0xFF001E50),
  'nissan': Color(0xFFC3002F),
  'honda': Color(0xFFCC0000),
  'ford': Color(0xFF003478),
  'chevrolet': Color(0xFFC29A00),
  'tesla': Color(0xFFE82127),
  'audi': Color(0xFFBB0A30),
  'porsche': Color(0xFFB12B28),
  'lexus': Color(0xFF1A1A1A),
  'land_rover': Color(0xFF005A2B),
  'jeep': Color(0xFF313131),
};

const _motorcycleLogoSlugOverrides = <String, String>{
  'harley_davidson': 'harley-davidson',
  'royal_enfield': 'royal-enfield',
  'mv_agusta': 'mv-agusta',
  'bmw': 'bmw-motorrad',
  'cfmoto': 'cf-moto',
  'moto_guzzi': 'moto-guzzi',
  'royal_alloy': 'royal-alloy',
  'regal_raptor': 'regal-raptor',
  'can_am': 'can-am',
};

String? vehicleBrandKeyFromSlug(String slug) {
  const marker = '_br_';
  final index = slug.indexOf(marker);
  if (index < 0) return null;
  final rest = slug.substring(index + marker.length);
  final end = rest.indexOf('_');
  return end < 0 ? rest : rest.substring(0, end);
}

bool isMotorcycleBrandSlug(String slug) => slug.startsWith('veh_moto_br_');

Color vehicleBrandColor(CategoryModel category, {Color fallback = const Color(0xFF757575)}) {
  final key = vehicleBrandKeyFromSlug(category.slug);
  if (key != null && _brandColors.containsKey(key)) {
    return _brandColors[key]!;
  }
  return fallback;
}

String vehicleBrandInitial(CategoryModel category) {
  final name = category.nameAr.trim();
  if (name.isEmpty) return '?';
  return name[0].toUpperCase();
}

/// True when [url] points to an SVG asset (Supabase Storage or external).
bool isSvgLogoUrl(String? url) {
  if (url == null || url.isEmpty) return false;
  final path = Uri.tryParse(url)?.path.toLowerCase() ?? url.toLowerCase();
  return path.endsWith('.svg');
}

/// Resolves logo URL from DB or carlogos.org pattern from brand slug.
String? vehicleBrandLogoUrl(CategoryModel category) {
  final stored = category.logoUrl?.trim();
  if (stored != null && stored.isNotEmpty) return stored;

  final key = vehicleBrandKeyFromSlug(category.slug);
  if (key == null || key.isEmpty) return null;

  if (isMotorcycleBrandSlug(category.slug)) {
    final slug = _motorcycleLogoSlugOverrides[key] ?? key.replaceAll('_', '-');
    return 'https://www.carlogos.org/motorcycle-logos/$slug-logo.png';
  }

  final slug = key.replaceAll('_', '-');
  return 'https://www.carlogos.org/car-logos/$slug-logo.png';
}
