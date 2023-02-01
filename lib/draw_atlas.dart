import 'dart:ui' as ui;

import 'package:atlas_performance_benchmark/main.dart';
import 'package:flutter/material.dart';

class AtlasPainter extends CustomPainter {
  final ui.Image atlas;

  AtlasPainter(
    this.atlas,
    Listenable listenable,
  ) : super(repaint: listenable);

  final defaultPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final atlasSize = atlas.width;
    final iterateCount = atlas.width / rectSize;

    final transforms = <RSTransform>[];
    final rects = <Rect>[];

    for (var i = 0; i < iterateCount; i++) {
      for (var j = 0; j < iterateCount; j++) {
        final left = i * rectSize;
        final top = j * rectSize;

        const scosAnchor = rectSize / 2; // 16

        transforms.add(RSTransform(1, 0, left - scosAnchor, top - scosAnchor));

        rects.add(Rect.fromLTWH(
          left,
          top,
          rectSize,
          rectSize,
        ));
      }
    }

    canvas.drawAtlas(
      atlas,
      transforms,
      rects,
      null,
      null,
      null,
      defaultPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
