import 'package:flutter/material.dart';

class SelectionPainter extends CustomPainter {
  const SelectionPainter({required this.selectionRect});

  final Rect? selectionRect;

  @override
  void paint(Canvas canvas, Size size) {
    final overlayRect = Offset.zero & size;
    final rect = selectionRect;

    canvas.drawRect(
      overlayRect,
      Paint()..color = Colors.black.withAlpha(110),
    );

    if (rect == null) {
      return;
    }

    canvas.saveLayer(overlayRect, Paint());
    canvas.drawRect(
      overlayRect,
      Paint()..color = Colors.black.withAlpha(110),
    );
    canvas.drawRect(rect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    canvas.drawRect(
      rect,
      Paint()
        ..color = Colors.orange
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(covariant SelectionPainter oldDelegate) {
    return oldDelegate.selectionRect != selectionRect;
  }
}