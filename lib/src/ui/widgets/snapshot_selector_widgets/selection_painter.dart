import 'package:flutter/material.dart';

class SelectionPainter extends CustomPainter {
  const SelectionPainter({required this.selectionRect});

  final Rect? selectionRect;

  @override
  void paint(Canvas canvas, Size size) {
    final canvasRect = Offset.zero & size;
    final rect = selectionRect;

    if (rect == null) {
      canvas.drawRect(
        canvasRect,
        Paint()..color = Colors.black.withAlpha(110),
      );
      return;
    }

    final outsideSelectionPath = Path.combine(
      PathOperation.difference,
      Path()..addRect(canvasRect),
      Path()..addRect(rect),
    );

    canvas.drawPath(
      outsideSelectionPath,
      Paint()..color = Colors.black.withAlpha(150),
    );

    canvas.drawRect(
      rect,
      Paint()..color = Colors.white.withAlpha(20),
    );

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
