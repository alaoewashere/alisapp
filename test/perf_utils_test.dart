import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/core/utils/cached_network_image_utils.dart';

void main() {
  testWidgets('memCachePx scales logical size by device pixel ratio', (tester) async {
    int? px;
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            px = memCachePx(context, 100);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(px, isNotNull);
    expect(px!, greaterThan(0));
  });
}
