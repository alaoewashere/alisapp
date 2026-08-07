import 'package:flutter/material.dart';

import '../../../core/router/app_router.dart';
import '../../../core/utils/navigation_guard.dart';

/// Navigates to the listing density heat map.
void openHomeHeatmap(BuildContext context) {
  context.pushGuarded(AppRoutes.heatmap);
}
