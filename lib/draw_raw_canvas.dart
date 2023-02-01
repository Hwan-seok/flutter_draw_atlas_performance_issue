import 'package:atlas_performance_benchmark/main.dart';
import 'package:flutter/material.dart';

class MyCustomPainter extends CustomPainter {
  final double atlasSize;
  final List<Color> colors;

  MyCustomPainter(
    Listenable listenable,
    this.atlasSize,
    this.colors,
  ) : super(repaint: listenable);

  @override
  void paint(Canvas canvas, Size size) {
    final iterateCount = atlasSize / rectSize;
    var paint = Paint();

    // var recorder = PictureRecorder();
    canvas.scale(0.05);
    for (var i = 0; i < iterateCount; i++) {
      ///
      for (var j = 0; j < iterateCount; j++) {
        final rect = Rect.fromLTWH(
          i * rectSize,
          j * rectSize,
          rectSize,
          rectSize,
        );
        canvas.drawRect(
          rect,
          paint..color = colors[iterateCount.toInt() * i + j],
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant MyCustomPainter oldDelegate) {
    return true;
  }
}
