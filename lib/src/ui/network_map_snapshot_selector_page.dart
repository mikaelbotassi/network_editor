import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_snapshot_service.dart';
import 'package:network_editor/src/ui/viewmodels/snapshot_selection_controller.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/crop_confirm_button.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/snapshot_select_body.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/snapshot_selector_appbar.dart';

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
  final _selectionController = SnapshotSelectionController();

  bool _isCropping = false;

  @override
  void dispose() {
    _selectionController.dispose();
    super.dispose();
  }

  Future<void> _confirmSelection(Size displayedSize) async {
    final selectionRect = _selectionController.selectionRect;
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
            return ListenableBuilder(
              listenable: _selectionController,
              builder: (context, _) => Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SnapshotSelectBody(
                        size: fittedSize,
                        image: widget.snapshot.bytes,
                        controller: _selectionController,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      child: CropConfirmButton(
                        enabled:
                            _selectionController.hasSelection && !_isCropping,
                        isLoading: _isCropping,
                        onPressed: () => _confirmSelection(fittedSize),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
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
