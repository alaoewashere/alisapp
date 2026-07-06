import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Sello/core/web/sello_web_ready_marker.dart';

void main() {
  testWidgets('SelloWebReadyMarker renders child', (tester) async {
    await tester.pumpWidget(
      const Directionality(
        textDirection: TextDirection.ltr,
        child: SelloWebReadyMarker(
          child: Text('hello'),
        ),
      ),
    );

    expect(find.text('hello'), findsOneWidget);
    await tester.pump();
  });
}
