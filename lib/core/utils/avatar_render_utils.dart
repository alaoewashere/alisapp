import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../constants/default_avatars.dart';

/// Renders a [DefaultAvatar] to PNG bytes for Supabase storage upload.
Future<Uint8List?> renderDefaultAvatarToPng(DefaultAvatar avatar) async {
  const size = 256.0;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  final center = Offset(size / 2, size / 2);

  final bgPaint = Paint()
    ..shader = LinearGradient(
      colors: avatar.gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, size, size));
  canvas.drawCircle(center, size / 2, bgPaint);

  final textPainter = TextPainter(
    text: TextSpan(
      text: avatar.emoji,
      style: TextStyle(fontSize: size * 0.46),
    ),
    textDirection: TextDirection.ltr,
  )..layout();

  textPainter.paint(
    canvas,
    Offset(
      (size - textPainter.width) / 2,
      (size - textPainter.height) / 2,
    ),
  );

  final picture = recorder.endRecording();
  final image = await picture.toImage(size.toInt(), size.toInt());
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  return byteData?.buffer.asUint8List();
}
