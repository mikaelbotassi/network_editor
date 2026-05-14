import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_snapshot_service.dart';
import 'package:network_editor/src/ui/widgets/core/alert.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/selection_painter.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/snapshot_selector_appbar.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class NetworkMapSnapshotSelectorPage extends StatefulWidget {
  const NetworkMapSnapshotSelectorPage({
    super.key,
    required this.snapshot,
  });

  final NetworkEditorSnapshot snapshot;

  @override
  State<NetworkMapSnapshotSelectorPage> createState() =>
      _NetworkMapSnapshotSelectorPageState();
}

class _NetworkMapSnapshotSelectorPageState
    extends State<NetworkMapSnapshotSelectorPage> {
  final _snapshotService = const NetworkEditorSnapshotService();

  Rect? _selectionRect;
  Offset? _dragStart;
  bool _isCropping = false;

  Future<void> _confirmSelection(Size displayedSize) async {
    final selectionRect = _selectionRect;
    if (selectionRect == null || _isCropping) {
      return;
    }

    setState(() => _isCropping = true);

    try {
      final normalizedRect = Rect.fromLTWH(
        selectionRect.left / displayedSize.width,
        selectionRect.top / displayedSize.height,
        selectionRect.width / displayedSize.width,
        selectionRect.height / displayedSize.height,
      );

      final croppedFile = await _snapshotService.cropImageToCache(
        sourceBytes: widget.snapshot.bytes,
        normalizedRect: normalizedRect,
        fileName: 'map_before_edit.png',
      );

      if (!mounted) return;
      Navigator.of(context).pop(croppedFile);
    } finally {
      if (mounted) {
        setState(() => _isCropping = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageSize = widget.snapshot.size;

    return Scaffold(
      appBar: SnaphotSelectorAppbar(),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final fittedSize = _containSize(
              source: imageSize,
              bounds: Size(constraints.maxWidth, constraints.maxHeight),
            );
            return Column(
              children: [
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: fittedSize.width,
                        height: fittedSize.height,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onPanStart: (details) {
                            final point = _clampOffset(
                              details.localPosition,
                              fittedSize,
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
                              fittedSize,
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
                              Image.memory(widget.snapshot.bytes, fit: BoxFit.fill),
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
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _selectionRect == null || _isCropping
                          ? null
                          : () => _confirmSelection(fittedSize),
                      child: _isCropping
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Usar recorte'),
                    ),
                  ),
                ),
              ],
            );
          },
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

  Size _containSize({
    required Size source,
    required Size bounds,
  }) {
    final sourceRatio = source.width / source.height;
    final boundsRatio = bounds.width / bounds.height;

    if (sourceRatio > boundsRatio) {
      return Size(bounds.width, bounds.width / sourceRatio);
    }

    return Size(bounds.height * sourceRatio, bounds.height);
  }
}
