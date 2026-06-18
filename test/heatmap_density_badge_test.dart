import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/features/listings/widgets/heatmap_density_badge.dart';

void main() {
  testWidgets('HeatmapDensityBadge renders listing count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HeatmapDensityBadge(count: 4),
        ),
      ),
    );

    expect(find.text('4'), findsOneWidget);
  });
}
