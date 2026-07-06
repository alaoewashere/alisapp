import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Reads config from `--dart-define` first, then dotenv when it was loaded.
///
/// On Flutter web, `.env` is not bundled unless listed in [pubspec.yaml] assets;
/// use `flutter run --dart-define-from-file=env.json` instead.
abstract final class EnvReader {
  static String optional(String key, {required String fromDefine}) {
    if (fromDefine.isNotEmpty) return fromDefine.trim();
    if (!dotenv.isInitialized) return '';
    return dotenv.env[key]?.trim() ?? '';
  }
}
