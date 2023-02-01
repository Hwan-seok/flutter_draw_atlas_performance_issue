import 'dart:math';
import 'dart:ui' as ui;

import 'package:atlas_performance_benchmark/draw_atlas.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const textureSize8k = 8192;
const rectSize = 32.0;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      showPerformanceOverlay: true,
      home: MyHome(),
    );
  }
}

class MyHome extends StatefulWidget {
  const MyHome({super.key});

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  late final animationController =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  double atlasSize = 64;

  ui.Image? capturedImage;
  Uint8List? capturedImageUin8List;

  ui.Image? flippImage;
  Uint8List? flippImageUin8List;

  bool drawImageView = true;
  bool drawCapturedImage = false;
  bool drawFlippedImage = false;

  @override
  void initState() {
    animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            const SizedBox.expand(),
            Column(
              children: [
                if (capturedImage != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (drawImageView && capturedImageUin8List != null)
                        Image.memory(
                          capturedImageUin8List!,
                          height: 100,
                        ),
                      if (drawCapturedImage)
                        CustomPaint(
                          size: const Size.square(200),
                          painter: AtlasPainter(
                            capturedImage!,
                            animationController,
                          ),
                        ),
                    ],
                  ),
                const SizedBox(height: 32),
                if (flippImage != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (drawImageView && flippImageUin8List != null)
                        Image.memory(
                          flippImageUin8List!,
                          height: 100,
                        ),
                      if (drawFlippedImage)
                        CustomPaint(
                          painter: AtlasPainter(
                            flippImage!,
                            animationController,
                          ),
                        ),
                    ],
                  ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final image = capturedImage = await record(atlasSize);
                    // capturedImageUin8List =
                    //     await convertFromImageToBytes(image);
                    // setState(() => null);
                    final flippedImage = flippImage = await flip(image);
                    // flippImageUin8List =
                    //     await convertFromImageToBytes(flippedImage);
                    // setState(() => null);
                  },
                  child: const Text("generate"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      setState(() => drawImageView = !drawImageView),
                  child: const Text("drawImageView"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      drawCapturedImage = !drawCapturedImage;
                    });
                  },
                  child: const Text("Draw Atlas"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      drawFlippedImage = !drawFlippedImage;
                    });
                  },
                  child: const Text("Draw Flipped Atlas"),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              width: 300,
              child: Slider(
                divisions: (textureSize8k ~/ rectSize) - 1,
                min: 32,
                value: atlasSize,
                max: 8192,
                label: atlasSize.toString(),
                onChanged: (value) => setState(() => atlasSize = value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<Uint8List?> convertFromImageToBytes(ui.Image image) async {
  return (await image.toByteData(format: ui.ImageByteFormat.png))
      ?.buffer
      .asUint8List();
}

Future<ui.Image> record(double atlasSize) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  // canvas.scale(15);
  draw(canvas, atlasSize);

  final picture = recorder.endRecording();

  final image = await picture.toImage(atlasSize.toInt(), atlasSize.toInt());
  picture.dispose();
  return image;
}

draw(Canvas canvas, double atlasSize) {
  const rectSize = 32.0;
  final iterateCount = atlasSize / rectSize;
  var paint = Paint();

  // canvas.scale(1);
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
        paint
          ..color = Colors.primaries[Random().nextInt(Colors.primaries.length)],
      );
    }
  }
}

Future<ui.Image> flip(ui.Image image) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  canvas.scale(-1, 1);
  canvas.drawImage(image, Offset(-image.width.toDouble(), 0), Paint());

  final picture = recorder.endRecording();
  final flippedImage = await picture.toImage(image.width, image.height);
  picture.dispose();
  return flippedImage;
}
