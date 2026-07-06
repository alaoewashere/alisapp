import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/config/env_reader.dart';
import 'package:Sello/core/supabase/supabase_client.dart';

void main() {
  group('EnvReader', () {
    test('returns empty when dotenv is not loaded and no dart-define', () {
      expect(
        EnvReader.optional('SUPABASE_URL', fromDefine: ''),
        isEmpty,
      );
    });

    test('prefers dart-define over dotenv', () {
      expect(
        EnvReader.optional(
          'SUPABASE_URL',
          fromDefine: 'https://example.supabase.co',
        ),
        'https://example.supabase.co',
      );
    });
  });

  group('SupabaseConfig without dotenv', () {
    test('isConfigured is false when env not provided', () {
      // No --dart-define in test VM; dotenv not loaded in tests.
      expect(SupabaseConfig.url, isEmpty);
      expect(SupabaseConfig.anonKey, isEmpty);
      expect(SupabaseConfig.isConfigured, isFalse);
    });
  });
}
