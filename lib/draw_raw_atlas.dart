import 'package:atlas_performance_benchmark/main.dart';
import 'package:flutter/material.dart';

class RawAtlasPainter extends CustomPainter {
  final RawAtlasBucket bucket;

  RawAtlasPainter(
    this.bucket,
    Listenable listenable,
  ) : super(repaint: listenable);

  final defaultPaint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRawAtlas(
      bucket.atlas,
      bucket.transforms,
      bucket.rects,
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
