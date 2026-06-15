import 'package:flutter_test/flutter_test.dart';

import 'package:my_app/models/smart_alert.dart';
import 'package:my_app/shared/models/filter_model.dart';

void main() {
  group('buildSmartAlertSummary', () {
    test('joins vehicle criteria with separators', () {
      final alert = SmartAlert(
        id: '1',
        userId: 'u1',
        title: 'لاند كروزر بغداد',
        category: 'المركبات',
        make: 'تويوتا',
        yearMin: 2020,
        yearMax: 2023,
        priceMin: 60000000,
        priceMax: 80000000,
        location: 'بغداد',
        createdAt: DateTime(2026, 6, 1),
      );

      expect(
        buildSmartAlertSummary(alert),
        'تويوتا • 2020-2023 • 60M-80M • بغداد',
      );
    });

    test('shows fallback when no filters', () {
      final alert = SmartAlert(
        id: '1',
        userId: 'u1',
        title: 'أي إعلان',
        createdAt: DateTime(2026, 6, 1),
      );

      expect(buildSmartAlertSummary(alert), 'بدون فلاتر إضافية');
    });
  });

  group('formatSmartAlertLastTriggered', () {
    test('shows not triggered yet', () {
      expect(formatSmartAlertLastTriggered(null), 'لم يُفعَّل بعد');
    });
  });

  group('isSmartAlertFreeLimitReached', () {
    test('blocks free users at 3 active alerts', () {
      expect(
        isSmartAlertFreeLimitReached(
          activeAlertCount: 3,
          hasProEntitlement: false,
        ),
        isTrue,
      );
    });

    test('allows pro users unlimited alerts', () {
      expect(
        isSmartAlertFreeLimitReached(
          activeAlertCount: 10,
          hasProEntitlement: true,
        ),
        isFalse,
      );
    });
  });

  group('smartAlertDraftFromFilter', () {
    test('maps search filters to draft', () {
      final draft = smartAlertDraftFromFilter(
        const FilterModel(
          query: 'لاند كروزر',
          governorate: 'baghdad',
          minPrice: 50000000,
          maxPrice: 90000000,
          condition: FilterCondition.used,
        ),
      );

      expect(draft.title, 'لاند كروزر');
      expect(draft.location, 'بغداد');
      expect(draft.priceMin, 50000000);
      expect(draft.priceMax, 90000000);
      expect(draft.condition, 'مستعمل');
    });
  });

  group('SmartAlert.fromJson', () {
    test('parses row from Supabase', () {
      final alert = SmartAlert.fromJson({
        'id': 'a1',
        'user_id': 'u1',
        'title': 'تنبيه',
        'category': 'المركبات',
        'make': 'BMW',
        'is_active': true,
        'created_at': '2026-06-01T10:00:00Z',
        'trigger_count': 4,
      });

      expect(alert.make, 'BMW');
      expect(alert.triggerCount, 4);
      expect(alert.isActive, isTrue);
    });
  });
}
