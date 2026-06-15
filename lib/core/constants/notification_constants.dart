import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OneSignal credentials — set in `.env` for local dev; DB trigger reads
/// `push_config` table (update via Supabase SQL after deploy).
String get kOneSignalAppId =>
    dotenv.env['ONESIGNAL_APP_ID'] ?? 'YOUR_ONESIGNAL_APP_ID';

String get kOneSignalRestApiKey =>
    dotenv.env['ONESIGNAL_REST_API_KEY'] ?? 'YOUR_ONESIGNAL_REST_API_KEY';

/// Free-tier cap on concurrently active smart alerts.
const kSmartAlertFreeLimit = 3;

/// Root browse categories shown in the alert form picker.
const kSmartAlertCategoryOptions = [
  'العقارات',
  'المركبات',
  'الإلكترونيات',
  'سوق المستعمل والجديد',
  'دروس خصوصية',
  'وظائف',
  'حيوانات',
  'خدمات منزلية',
];

/// Arabic vehicle category label — shows make/model fields when selected.
const kSmartAlertVehicleCategory = 'المركبات';
