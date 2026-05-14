import 'dart:typed_data';

import 'package:flutter/material.dart';

class SnapshotSelectBody extends StatefulWidget {
  const SnapshotSelectBody({
    required this.size,
    required this.onChanged,
    required this.image,
    super.key,
  });

  final Size size;
  final Uint8List image;
  final Function(Offset dragStart, Rect selectionRect) onChanged;

  @override
  State<SnapshotSelectBody> createState() => _SnapshotSelectBodyState();
}

class _SnapshotSelectBodyState extends State<SnapshotSelectBody> {

  Rect? _selectionRect;
  Offset? _dragStart;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size.width,
        height: widget.size.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            final point = _clampOffset(
              details.localPosition,
              widget.size,
            );
            setState(() {
              _dragStart = point;
              _selectionRect = Rect.fromLTWH(
                point.dx,
                point.dy,
                0,
                0,
              );
            });
          },
          onPanUpdate: (details) {
            final dragStart = _dragStart;
            if (dragStart == null) return;

            final point = _clampOffset(
              details.localPosition,
              widget.size,
            );
            setState(() {
              _selectionRect = Rect.fromPoints(dragStart, point);
            });
          },
          onPanEnd: (_) {
            setState(() {
              _dragStart = null;
              _selectionRect = _normalizeSelection(_selectionRect);
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(widget.image, fit: BoxFit.fill),
              CustomPaint(
                painter: SelectionPainter(
                  selectionRect: _selectionRect,
                ),
              ),
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Alert(
                    icon: TablerIcons.infoCircle,
                    color: Colors.blue,
                    text: 'Arraste para selecionar a parte do mapa que sera usada no editor.'
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Rect? _normalizeSelection(Rect? rect) {
    if (rect == null) return null;
    if (rect.width < 24 || rect.height < 24) {
      return null;
    }
    return rect;
  }

  Offset _clampOffset(Offset point, Size bounds) {
    return Offset(
      point.dx.clamp(0.0, bounds.width),
      point.dy.clamp(0.0, bounds.height),
    );
  }

}
