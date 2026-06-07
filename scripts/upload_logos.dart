// Upload car brand SVG logos to Supabase Storage and update categories.logo_url.
//
// Prerequisites:
//   1. Run migration 20260616000000_brand_logos_storage.sql in Supabase
//   2. Set SUPABASE_SERVICE_ROLE_KEY (in admin/.env.local or environment)
//
// Usage (from project root):
//   dart run scripts/upload_logos.dart
//   dart run scripts/upload_logos.dart --electronics
//   dart run scripts/upload_logos.dart --dry-run
//
// Verify in Supabase SQL Editor:
//   SELECT name_ar, logo_url FROM categories
//   WHERE logo_url IS NOT NULL AND icon = 'brand'
//   ORDER BY name_ar;

import 'dart:io';
import 'dart:typed_data';

import 'package:supabase/supabase.dart';

const _bucket = 'brand-logos';
const _userAgent = 'SouqIQ/1.0 (https://github.com/souqiq; dev@souqiq.app)';
const _downloadDelay = Duration(milliseconds: 1200);

/// Brand display name (categories.name_ar) → Wikipedia Commons SVG source URL.
/// Paths verified via Wikimedia API (June 2026); some user-provided hashes were stale.
const _brandSources = <String, String>{
  'Toyota': 'https://upload.wikimedia.org/wikipedia/commons/9/9d/Toyota_carlogo.svg',
  'Kia': 'https://upload.wikimedia.org/wikipedia/commons/b/b6/KIA_logo3.svg',
  'Hyundai':
      'https://upload.wikimedia.org/wikipedia/commons/4/44/Hyundai_Motor_Company_logo.svg',
  'Nissan':
      'https://upload.wikimedia.org/wikipedia/commons/4/4f/Nissan_logo_2001.svg',
  'Mercedes-Benz':
      'https://upload.wikimedia.org/wikipedia/commons/9/90/Mercedes-Logo.svg',
  'Volkswagen':
      'https://upload.wikimedia.org/wikipedia/commons/6/6d/Volkswagen_logo_2019.svg',
  'Ford': 'https://upload.wikimedia.org/wikipedia/commons/3/3e/Ford_logo_flat.svg',
  'GMC': 'https://upload.wikimedia.org/wikipedia/commons/f/f9/GMC-Logo_2.svg',
  'Mitsubishi':
      'https://upload.wikimedia.org/wikipedia/commons/5/5a/Mitsubishi_logo.svg',
  'Honda': 'https://upload.wikimedia.org/wikipedia/commons/7/7b/Honda_Logo.svg',
  'Chrysler':
      'https://upload.wikimedia.org/wikipedia/commons/d/d5/Chrysler_1998_wordmark.svg',
  'Renault':
      'https://upload.wikimedia.org/wikipedia/commons/b/b7/Renault_2021_Text.svg',
  'Mazda':
      'https://upload.wikimedia.org/wikipedia/commons/b/b6/Mazda_logo_with_emblem%2C_new.svg',
  'Isuzu': 'https://upload.wikimedia.org/wikipedia/commons/4/49/Isuzu.svg',
  'Opel': 'https://upload.wikimedia.org/wikipedia/commons/7/70/Opel_Logo_2021.svg',
  'BMW': 'https://upload.wikimedia.org/wikipedia/commons/4/44/BMW.svg',
  'Audi': 'https://upload.wikimedia.org/wikipedia/commons/9/92/Audi-Logo_2016.svg',
  'Porsche':
      'https://upload.wikimedia.org/wikipedia/commons/3/3b/Porsche_Wortmarke.svg',
  'Tesla': 'https://upload.wikimedia.org/wikipedia/commons/b/bd/Tesla_Motors.svg',
  'Volvo': 'https://upload.wikimedia.org/wikipedia/commons/5/54/Volvo_logo.svg',
  'Polestar':
      'https://upload.wikimedia.org/wikipedia/commons/7/71/Polestar_logo_2020.svg',
  'NIO': 'https://upload.wikimedia.org/wikipedia/commons/c/ca/NIO_logo.svg',
  'BYD': 'https://upload.wikimedia.org/wikipedia/commons/0/0e/BYD_Auto_Logo.svg',
  'Lexus': 'https://upload.wikimedia.org/wikipedia/commons/7/75/Lexus.svg',
  'Chevrolet':
      'https://upload.wikimedia.org/wikipedia/commons/8/81/Chevrolet-logo.svg',
  'Jeep': 'https://upload.wikimedia.org/wikipedia/commons/0/0d/Jeep_logo.svg',
  'MINI': 'https://upload.wikimedia.org/wikipedia/commons/e/e9/MINI_logo.svg',
  'Jaguar': 'https://upload.wikimedia.org/wikipedia/commons/5/50/Jaguar_2024.svg',
  'Land Rover':
      'https://upload.wikimedia.org/wikipedia/commons/c/c2/Land_Rover_2023.svg',
  'Rivian': 'https://upload.wikimedia.org/wikipedia/commons/5/54/Rivian_logo.svg',
  'Hino': 'https://upload.wikimedia.org/wikipedia/commons/d/d4/Hino_logo.svg',
  'IVECO': 'https://upload.wikimedia.org/wikipedia/commons/f/f7/Iveco_Logo_2023.svg',
  'MAN': 'https://upload.wikimedia.org/wikipedia/commons/f/f7/MAN_Truck_%26_Bus_-_Logo_2.svg',
  'Mitsubishi Fuso':
      'https://upload.wikimedia.org/wikipedia/commons/5/5a/Mitsubishi_logo.svg',
  'Renault Trucks':
      'https://upload.wikimedia.org/wikipedia/commons/b/b7/Renault_2021_Text.svg',
  'Nissan UD':
      'https://upload.wikimedia.org/wikipedia/commons/4/4f/Nissan_logo_2001.svg',
  'DAF': 'https://upload.wikimedia.org/wikipedia/commons/1/12/DAF_logo.svg',
  'Foton': 'https://upload.wikimedia.org/wikipedia/commons/f/fa/Foton_Motor_logo.svg',
  'Dongfeng':
      'https://upload.wikimedia.org/wikipedia/commons/e/eb/Dongfeng_Motor_logo.svg',
};

/// PNG fallbacks (carlogos.org) for brands without reliable Commons SVG.
const _pngBrandSources = <String, String>{
  'Dodge': 'https://www.carlogos.org/car-logos/dodge-logo.png',
  'Rolls-Royce': 'https://www.carlogos.org/car-logos/rolls-royce-logo.png',
  'Cadillac': 'https://www.carlogos.org/car-logos/cadillac-logo.png',
  'Alfa Romeo': 'https://www.carlogos.org/car-logos/alfa-romeo-logo.png',
  'Ferrari': 'https://www.carlogos.org/car-logos/ferrari-logo.png',
  'Lincoln': 'https://www.carlogos.org/car-logos/lincoln-logo.png',
  'Pontiac': 'https://www.carlogos.org/car-logos/pontiac-logo.png',
  'Oldsmobile': 'https://www.carlogos.org/car-logos/oldsmobile-logo.png',
};

/// Electronics brand logos — verified June 2026 (simple-icons, worldvectorlogo, Wikimedia).
const _electronicsBrandSources = <String, String>{
  'Apple':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/apple.svg',
  'Samsung':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/samsung.svg',
  'Huawei':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/huawei.svg',
  'Xiaomi':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/xiaomi.svg',
  'Oppo':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/oppo.svg',
  'Vivo':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/vivo.svg',
  'OnePlus':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/oneplus.svg',
  'Tecno': 'https://www.tecno-mobile.com/icons/logo.svg',
  'Infinix': 'https://cdn.worldvectorlogo.com/logos/infinix-1.svg',
  'Dell':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/dell.svg',
  'HP': 'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/hp.svg',
  'Lenovo':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/lenovo.svg',
  'Asus':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/asus.svg',
  'MSI':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/msi.svg',
  'LG': 'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/lg.svg',
  'Sony':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/sony.svg',
  'TCL': 'https://cdn.worldvectorlogo.com/logos/tcl-1.svg',
  'Canon': 'https://upload.wikimedia.org/wikipedia/commons/8/8d/Canon_logo.svg',
  'Nikon':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/nikon.svg',
  'GoPro': 'https://cdn.worldvectorlogo.com/logos/gopro-2.svg',
  'JBL':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/jbl.svg',
  'Bose':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/bose.svg',
  'Sony PlayStation': 'https://cdn.worldvectorlogo.com/logos/playstation-2.svg',
  'Microsoft Xbox': 'https://cdn.worldvectorlogo.com/logos/xbox-one-2.svg',
  'Nintendo': 'https://cdn.worldvectorlogo.com/logos/nintendo-2.svg',
  'TP-Link':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/tplink.svg',
  'Cisco':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/cisco.svg',
  'Epson':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/epson.svg',
  'Bosch':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/bosch.svg',
  'Siemens':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/siemens.svg',
  'Electrolux': 'https://cdn.worldvectorlogo.com/logos/electrolux-1.svg',
  'Whirlpool': 'https://cdn.worldvectorlogo.com/logos/whirlpool-1.svg',
  'Haier': 'https://cdn.worldvectorlogo.com/logos/haier.svg',
  'Midea': 'https://cdn.worldvectorlogo.com/logos/midea-1.svg',
  'Gree': 'https://cdn.worldvectorlogo.com/logos/gree-1.svg',
  'Carrier': 'https://cdn.worldvectorlogo.com/logos/carrier-1.svg',
  'Daikin': 'https://cdn.worldvectorlogo.com/logos/daikin-1.svg',
  'Toshiba':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/toshiba.svg',
  'Hitachi':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/hitachi.svg',
  'Panasonic':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/panasonic.svg',
  'York': 'https://cdn.worldvectorlogo.com/logos/york-1.svg',
  'DJI':
      'https://raw.githubusercontent.com/simple-icons/simple-icons/develop/icons/dji.svg',
  'BenQ': 'https://cdn.worldvectorlogo.com/logos/benq-1.svg',
  'ViewSonic': 'https://cdn.worldvectorlogo.com/logos/viewsonic-1.svg',
};

Future<void> main(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final electronicsOnly = args.contains('--electronics');
  String? onlyArg;
  for (final a in args) {
    if (a.startsWith('--only=')) {
      onlyArg = a.substring(7);
      break;
    }
  }
  final onlyBrands = onlyArg?.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toSet();
  final env = _loadEnv([
    '.env',
    'admin/.env.local',
  ]);

  final supabaseUrl =
      env['SUPABASE_URL'] ?? env['NEXT_PUBLIC_SUPABASE_URL'] ?? '';
  final serviceKey = env['SUPABASE_SERVICE_ROLE_KEY'] ?? '';

  if (supabaseUrl.isEmpty) {
    stderr.writeln('Missing SUPABASE_URL (set in .env or admin/.env.local)');
    exit(1);
  }
  if (serviceKey.isEmpty && !dryRun) {
    stderr.writeln(
      'Missing SUPABASE_SERVICE_ROLE_KEY — required for upload/update.',
    );
    exit(1);
  }

  final client = SupabaseClient(supabaseUrl, serviceKey);
  final http = HttpClient()..userAgent = _userAgent;

  var uploaded = 0;
  var updated = 0;
  var failed = 0;

  Future<void> uploadBrand({
    required String brandName,
    required String sourceUrl,
    required String objectPath,
    required String contentType,
  }) async {
    try {
      stdout.writeln('→ $brandName');

      if (dryRun) {
        stdout.writeln('  would upload $objectPath from $sourceUrl');
        return;
      }

      final bytes = await _download(http, sourceUrl, accept: contentType);
      if (bytes.isEmpty) {
        throw StateError('empty response from $sourceUrl');
      }

      await client.storage.from(_bucket).uploadBinary(
            objectPath,
            Uint8List.fromList(bytes),
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      final publicUrl = client.storage.from(_bucket).getPublicUrl(objectPath);
      uploaded++;

      var updateQuery = client
          .from('categories')
          .update({'logo_url': publicUrl})
          .eq('name_ar', brandName)
          .eq('icon', 'brand');
      if (electronicsOnly) {
        updateQuery = updateQuery.like('slug', 'elec_%');
      }
      final rows = await updateQuery.select('id');

      final count = (rows as List).length;
      updated += count;
      stdout.writeln('  ✓ $objectPath → $count category row(s)');
      stdout.writeln('    $publicUrl');

      await Future<void>.delayed(_downloadDelay);
    } catch (e, st) {
      failed++;
      stderr.writeln('  ✗ $brandName: $e');
      if (args.contains('--verbose')) {
        stderr.writeln(st);
      }
    }
  }

  if (electronicsOnly) {
    for (final entry in _electronicsBrandSources.entries) {
      final brandName = entry.key;
      if (onlyBrands != null && !onlyBrands.contains(brandName)) continue;
      await uploadBrand(
        brandName: brandName,
        sourceUrl: entry.value,
        objectPath: 'elec-${_storageFileName(brandName)}.svg',
        contentType: 'image/svg+xml',
      );
    }
  } else {
    for (final entry in _brandSources.entries) {
      final brandName = entry.key;
      if (onlyBrands != null && !onlyBrands.contains(brandName)) continue;
      await uploadBrand(
        brandName: brandName,
        sourceUrl: entry.value,
        objectPath: '${_storageFileName(brandName)}.svg',
        contentType: 'image/svg+xml',
      );
    }

    for (final entry in _pngBrandSources.entries) {
      final brandName = entry.key;
      if (onlyBrands != null && !onlyBrands.contains(brandName)) continue;
      await uploadBrand(
        brandName: brandName,
        sourceUrl: entry.value,
        objectPath: '${_storageFileName(brandName)}.png',
        contentType: 'image/png',
      );
    }
  }

  http.close(force: true);

  stdout.writeln('');
  stdout.writeln(
    'Done: $uploaded uploaded, $updated category rows updated, $failed failed.',
  );

  if (failed > 0) exit(1);
}

Map<String, String> _loadEnv(List<String> paths) {
  final env = <String, String>{};
  for (final relative in paths) {
    final file = File(relative);
    if (!file.existsSync()) continue;
    for (final line in file.readAsLinesSync()) {
      final trimmed = line.trim();
      if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
      final eq = trimmed.indexOf('=');
      if (eq <= 0) continue;
      final key = trimmed.substring(0, eq).trim();
      var value = trimmed.substring(eq + 1).trim();
      if (value.startsWith('"') && value.endsWith('"')) {
        value = value.substring(1, value.length - 1);
      }
      env[key] = value;
    }
  }
  env.addAll(Platform.environment);
  return env;
}

String _storageFileName(String brandName) {
  return brandName
      .toLowerCase()
      .replaceAll('&', 'and')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
}

Future<List<int>> _download(
  HttpClient http,
  String url, {
  String accept = 'image/svg+xml,*/*',
}) async {
  const maxAttempts = 4;
  for (var attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await _downloadOnce(http, url, accept: accept);
    } on HttpException catch (e) {
      final retryable = e.message.contains('429') || e.message.contains('503');
      if (!retryable || attempt == maxAttempts) rethrow;
      final wait = Duration(seconds: attempt * 2);
      stderr.writeln('  retry $attempt after ${wait.inSeconds}s (${e.message})');
      await Future<void>.delayed(wait);
    }
  }
  throw StateError('unreachable');
}

Future<List<int>> _downloadOnce(
  HttpClient http,
  String url, {
  String accept = 'image/svg+xml,*/*',
}) async {
  final uri = Uri.parse(url);
  final request = await http.getUrl(uri);
  request.headers.set('Accept', accept);
  request.headers.set('User-Agent', _userAgent);
  final response = await request.close();
  if (response.statusCode != 200) {
    throw HttpException('HTTP ${response.statusCode} for $url');
  }
  return await response.fold<List<int>>(
    <int>[],
    (previous, element) => previous..addAll(element),
  );
}
