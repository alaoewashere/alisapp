import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:Sello/core/constants/car_paint_panels.dart';
import 'package:Sello/core/l10n/car_paint_locale.dart';
import 'package:Sello/l10n/app_localizations.dart';

void main() {
  test('carPaintConditionLabel returns English labels', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(
      carPaintConditionLabel(l10n, CarPaintCondition.localPaint),
      'Local Paint',
    );
    expect(carPaintConditionLabel(l10n, CarPaintCondition.painted), 'Painted');
    expect(
      carPaintConditionLabel(l10n, CarPaintCondition.replaced),
      'Replaced',
    );
    expect(carPaintConditionLabel(l10n, CarPaintCondition.original), 'Original');
  });

  test('carPaintPanelLabel returns localized panel names', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(carPaintPanelLabel(l10n, 'hood'), 'Hood');
    expect(carPaintPanelLabel(l10n, 'front_bumper'), 'Front bumper');
  });

  test('bodyPartSelected formats counter', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(l10n.bodyPartSelected(0, 13), '0/13 parts selected');
    expect(l10n.bodyPartSelected(3, 13), '3/13 parts selected');
  });
}
