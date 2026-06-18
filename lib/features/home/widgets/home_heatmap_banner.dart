import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';

/// Navigates to the listing density heat map.
void openHomeHeatmap(BuildContext context) {
  context.push(AppRoutes.heatmap);
}
