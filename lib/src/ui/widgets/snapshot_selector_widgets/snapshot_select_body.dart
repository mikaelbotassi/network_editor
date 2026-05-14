import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:network_editor/src/ui/viewmodels/snapshot_selection_controller.dart';
import 'package:network_editor/src/ui/widgets/core/alert.dart';
import 'package:network_editor/src/ui/widgets/snapshot_selector_widgets/selection_painter.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

class SnapshotSelectBody extends StatelessWidget {
  const SnapshotSelectBody({
    required this.size,
    required this.image,
    required this.controller,
    super.key,
  });

  final Size size;
  final Uint8List image;
  final SnapshotSelectionController controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
            controller.startSelection(
              localPosition: details.localPosition,
              bounds: size,
            );
          },
          onPanUpdate: (details) {
            controller.updateSelection(
              localPosition: details.localPosition,
              bounds: size,
            );
          },
          onPanEnd: (_) {
            controller.endSelection();
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.memory(image, fit: BoxFit.fill),
              CustomPaint(
                painter: SelectionPainter(
                  selectionRect: controller.selectionRect,
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
}
