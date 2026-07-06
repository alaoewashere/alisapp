import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_provider.dart';
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
    final strings = context.l10n;
    return FeatureTutorialOverlay(
      targetKey: targetKey,
      onDismiss: onDismiss,
      title: strings.heatmapTutorialTitle,
      subtitle: strings.heatmapTutorialSubtitle,
    );
  }
}
