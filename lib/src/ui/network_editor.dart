import 'dart:async';
import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_editor_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class NetworkEditorWidget extends StatefulWidget {
  final NetworkEditorController controller;
  final List<Positioned> overlayItems;
  final ValueChanged<NetworkEditorResult>? onSave;
  final Future<void> Function(EditorNode node)? onNodeTap;
  final Future<void> Function(EditorSegment segment)? onSegmentTap;

  const NetworkEditorWidget({
    super.key,
    required this.controller,
    this.onSave,
    this.onNodeTap,
    this.onSegmentTap,
    this.overlayItems = const [],
  });

  @override
  State<NetworkEditorWidget> createState() => _NetworkEditorWidgetState();
}

class _NetworkEditorWidgetState extends State<NetworkEditorWidget> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(covariant NetworkEditorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_refresh);
      widget.controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    widget.controller.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _processAction(NetworkInteractionResult result) async {
    if (result is NodeTappedResult && widget.onNodeTap != null) {
      await widget.onNodeTap!(result.node);
      return;
    }

    if (result is SegmentTappedResult && widget.onSegmentTap != null) {
      await widget.onSegmentTap!(result.segment);
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: controller.initialCenter,
              initialZoom: controller.initialZoom,
              onTap: controller.onMapTap,
            ),
            children: [
              if (controller.baseTileLayer != null) controller.baseTileLayer!,
              if (controller.showDarkBackground)
                const ColoredBox(color: Colors.black),

              PolylineLayer(
                polylines: controller.buildPolylines(
                  onSegmentTap: (segment) async {
                    final result = controller.handleSegmentTap(segment);
                    await _processAction(result);
                  },
                ),
              ),

              MarkerLayer(
                markers: controller.buildMarkers(
                  onTapNode: (node) async {
                    final result = controller.handleNodeTap(node);
                    await _processAction(result);
                  },
                ),
              ),
            ],
          ),
          ...widget.overlayItems
        ],
      ),
      floatingActionButton: NetworkMapEditorToolbar(controller: controller),
    );
  }
}