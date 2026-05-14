import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class NetworkEditorSnapshot {
  const NetworkEditorSnapshot({
    required this.file,
    required this.bytes,
    required this.size,
  });

  final File file;
  final Uint8List bytes;
  final Size size;
}

class NetworkEditorSnapshotService {
  const NetworkEditorSnapshotService();

  Future<NetworkEditorSnapshot> captureToCache({
    required GlobalKey boundaryKey,
    String fileName = 'network_editor_snapshot.png',
    double pixelRatio = 2,
  }) async {
    final context = boundaryKey.currentContext;
    if (context == null) {
      throw StateError('Capture boundary context not found.');
    }

    final renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      throw StateError('Capture target is not a RenderRepaintBoundary.');
    }

    final ui.Image image = await renderObject.toImage(
      pixelRatio: pixelRatio,
    );

    final byteData = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw StateError('Could not convert captured image to PNG bytes.');
    }

    final Uint8List bytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');

    await file.writeAsBytes(bytes, flush: true);

    return NetworkEditorSnapshot(
      file: file,
      bytes: bytes,
      size: Size(
        image.width.toDouble(),
        image.height.toDouble(),
      ),
    );
  }

  Future<File> cropImageToCache({
    required Uint8List sourceBytes,
    required Rect normalizedRect,
    String fileName = 'network_editor_snapshot_cropped.png',
  }) async {
    final codec = await ui.instantiateImageCodec(sourceBytes);
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final left = normalizedRect.left.clamp(0.0, 1.0);
    final top = normalizedRect.top.clamp(0.0, 1.0);
    final width = normalizedRect.width.clamp(0.0, 1.0 - left);
    final height = normalizedRect.height.clamp(0.0, 1.0 - top);

    final safeRect = Rect.fromLTWH(
      left,
      top,
      width,
      height,
    );

    final srcRect = Rect.fromLTWH(
      safeRect.left * image.width,
      safeRect.top * image.height,
      safeRect.width * image.width,
      safeRect.height * image.height,
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint();
    final dstRect = Rect.fromLTWH(0, 0, srcRect.width, srcRect.height);
    canvas.drawImageRect(image, srcRect, dstRect, paint);

    final croppedImage = await recorder.endRecording().toImage(
      srcRect.width.round(),
      srcRect.height.round(),
    );

    final byteData = await croppedImage.toByteData(
      format: ui.ImageByteFormat.png,
    );

    if (byteData == null) {
      throw StateError('Could not convert cropped image to PNG bytes.');
    }

    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);

    return file;
  }
}
