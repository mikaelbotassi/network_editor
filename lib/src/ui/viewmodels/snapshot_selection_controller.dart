import 'package:flutter/material.dart';

class SnapshotSelectionController extends ChangeNotifier {
  Rect? get selectionRect => _selectionRect;
  Rect? _selectionRect;

  Offset? _dragStart;

  bool get hasSelection => _selectionRect != null;

  void startSelection({
    required Offset localPosition,
    required Size bounds,
  }) {
    final point = _clampOffset(localPosition, bounds);
    _dragStart = point;
    _selectionRect = Rect.fromLTWH(point.dx, point.dy, 0, 0);
    notifyListeners();
  }

  void updateSelection({
    required Offset localPosition,
    required Size bounds,
  }) {
    final dragStart = _dragStart;
    if (dragStart == null) {
      return;
    }

    final point = _clampOffset(localPosition, bounds);
    _selectionRect = Rect.fromPoints(dragStart, point);
    notifyListeners();
  }

  void endSelection() {
    _dragStart = null;
    _selectionRect = _normalizeSelection(_selectionRect);
    notifyListeners();
  }

  Offset _clampOffset(Offset point, Size bounds) {
    return Offset(
      point.dx.clamp(0.0, bounds.width),
      point.dy.clamp(0.0, bounds.height),
    );
  }

  Rect? _normalizeSelection(Rect? rect) {
    if (rect == null) return null;
    if (rect.width < 24 || rect.height < 24) {
      return null;
    }
    return rect;
  }
}
