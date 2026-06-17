import 'package:flutter_dotenv/flutter_dotenv.dart';

/// OneSignal app id for client SDK — set via dart-define or local `.env`.
String get kOneSignalAppId =>
    const String.fromEnvironment('ONESIGNAL_APP_ID').isNotEmpty
        ? const String.fromEnvironment('ONESIGNAL_APP_ID')
        : (dotenv.isInitialized
            ? (dotenv.env['ONESIGNAL_APP_ID'] ?? 'YOUR_ONESIGNAL_APP_ID')
            : 'YOUR_ONESIGNAL_APP_ID');

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
