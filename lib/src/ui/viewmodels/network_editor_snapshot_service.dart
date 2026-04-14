import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';

class NetworkEditorSnapshotService {
  const NetworkEditorSnapshotService();

  Future<File> captureToCache({
    required GlobalKey boundaryKey,
    String fileName = 'network_editor_snapshot.png',
    double pixelRatio = 3,
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

    return file;
  }
}