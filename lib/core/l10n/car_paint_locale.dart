import '../../l10n/app_localizations.dart';
import '../constants/car_paint_panels.dart';

/// Localized display label for a stored paint condition value (DB stays English keys).
String carPaintConditionLabel(AppLocalizations l10n, String condition) {
  return switch (condition) {
    CarPaintCondition.localPaint => l10n.bodyPartLocalPaint,
    CarPaintCondition.painted => l10n.bodyPartPainted,
    CarPaintCondition.replaced => l10n.bodyPartReplaced,
    _ => l10n.bodyPartOriginal,
  };
}

/// Localized panel name for bottom sheet title and summary lists.
String carPaintPanelLabel(AppLocalizations l10n, String panelKey) {
  return switch (panelKey) {
    'front_bumper' => l10n.carPaintPanelFrontBumper,
    'hood' => l10n.carPaintPanelHood,
    'front_left_fender' => l10n.carPaintPanelFrontLeftFender,
    'front_right_fender' => l10n.carPaintPanelFrontRightFender,
    'front_left_door' => l10n.carPaintPanelFrontLeftDoor,
    'front_right_door' => l10n.carPaintPanelFrontRightDoor,
    'roof' => l10n.carPaintPanelRoof,
    'rear_left_door' => l10n.carPaintPanelRearLeftDoor,
    'rear_right_door' => l10n.carPaintPanelRearRightDoor,
    'trunk' => l10n.carPaintPanelTrunk,
    'rear_left_fender' => l10n.carPaintPanelRearLeftFender,
    'rear_right_fender' => l10n.carPaintPanelRearRightFender,
    'rear_bumper' => l10n.carPaintPanelRearBumper,
    _ => panelKey.replaceAll('_', ' '),
  };
}
