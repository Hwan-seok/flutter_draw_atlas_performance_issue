// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';
import 'dart:ui' as ui;

import 'package:atlas_performance_benchmark/draw_atlas.dart';
import 'package:atlas_performance_benchmark/draw_raw_atlas.dart';
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
  RawAtlasBucket? rawAtlasBucket;

  ui.Image? flippImage;
  RawAtlasBucket? flippRawAtlasBucket;

  bool drawRawAtlas = true;
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
                if (capturedImage != null &&
                    drawCapturedImage &&
                    rawAtlasBucket != null)
                  CustomPaint(
                    size: const Size.square(200),
                    painter: drawRawAtlas
                        ? RawAtlasPainter(
                            rawAtlasBucket!,
                            animationController,
                          )
                        : AtlasPainter(
                            capturedImage!,
                            animationController,
                          ),
                  ),
                const SizedBox(height: 32),
                if (flippImage != null &&
                    drawFlippedImage &&
                    flippRawAtlasBucket != null)
                  CustomPaint(
                    painter: drawRawAtlas
                        ? RawAtlasPainter(
                            flippRawAtlasBucket!,
                            animationController,
                          )
                        : AtlasPainter(
                            flippImage!,
                            animationController,
                          ),
                  ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("using raw: $drawRawAtlas"),
                ElevatedButton(
                  onPressed: () => setState(() => drawRawAtlas = !drawRawAtlas),
                  child: const Text(
                      "Toggle whether using drawRawAtlas or drawAtlas"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      drawCapturedImage = !drawCapturedImage;
                    });
                  },
                  child: const Text("Toggle Drawing Atlas"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      drawFlippedImage = !drawFlippedImage;
                    });
                  },
                  child: const Text("Toggle Drawing Flipped Atlas"),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              right: 0,
              width: 300,
              child: Slider(
                onChangeEnd: (value) async {
                  atlasSize = value;
                  setState(() => null);
                  final image = capturedImage = await record(atlasSize);
                  final flippedImage = flippImage = await flip(image);

                  rawAtlasBucket = createAtlas(image);
                  flippRawAtlasBucket = createAtlas(flippedImage);

                  setState(() => null);
                },
                divisions: (textureSize8k ~/ rectSize) - 1,
                min: 32,
                value: atlasSize,
                max: 8192,
                label: atlasSize.toString(),
                onChanged: (value) {},
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

  for (var i = 0; i < iterateCount; i++) {
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

/// this is just a flip but any manipulating from original image is the same.
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

RawAtlasBucket createAtlas(ui.Image atlas) {
  final atlasSize = atlas.width;
  final oneRowRectCount = atlasSize ~/ rectSize;
  final rectCount = pow(oneRowRectCount, 2).toInt();
  final transforms = Float32List(rectCount * 4);
  final rects = Float32List(rectCount * 4);

  const scosAnchor = rectSize / 2; // 16

  for (var idx = 0; idx < rectCount; idx++) {
    final i = idx ~/ oneRowRectCount;
    final j = idx - i * oneRowRectCount;

    final left = i * rectSize;
    final top = j * rectSize;

    final int index0 = idx * 4;
    final int index1 = index0 + 1;
    final int index2 = index0 + 2;
    final int index3 = index0 + 3;

    rects[index0] = left;
    rects[index1] = top;
    rects[index2] = left + rectSize;
    rects[index3] = top + rectSize;

    transforms[index0] = 1;
    transforms[index1] = 0;
    transforms[index2] = left - scosAnchor;
    transforms[index3] = top - scosAnchor;
  }

  return RawAtlasBucket(atlas: atlas, transforms: transforms, rects: rects);
}

class RawAtlasBucket {
  final ui.Image atlas;
  final Float32List transforms;
  final Float32List rects;

  RawAtlasBucket({
    required this.atlas,
    required this.transforms,
    required this.rects,
  });
}
