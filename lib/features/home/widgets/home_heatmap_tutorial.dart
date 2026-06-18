import 'package:flutter/material.dart';

import '../../../shared/widgets/feature_tutorial_overlay.dart';

/// One-time coachmark spotlighting the heat-map header icon.
class HomeHeatmapTutorialOverlay extends StatelessWidget {
  const HomeHeatmapTutorialOverlay({
    super.key,
    required this.targetKey,
    required this.onDismiss,
  });

  final GlobalKey targetKey;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return FeatureTutorialOverlay(
      targetKey: targetKey,
      onDismiss: onDismiss,
      title: 'اكتشف كثافة الإعلانات في منطقتك على الخريطة',
      subtitle: 'اضغط على أيقونة الخريطة لعرض المناطق الأكثر نشاطاً',
    );
  }
}
