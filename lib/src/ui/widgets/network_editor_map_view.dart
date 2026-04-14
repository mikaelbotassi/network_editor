import 'dart:io';

import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/enums/network_view.dart';
import 'package:electric_digital_sketch/src/ui/viewmodels/network_editor_snapshot_service.dart';
import 'package:electric_digital_sketch/src/ui/network_image_editor_page.dart';
import 'package:electric_digital_sketch/src/ui/widgets/overlay_items/network_image_editor_buttom.dart';
import 'package:electric_digital_sketch/src/ui/widgets/overlay_items/recenter_button.dart';
import 'package:electric_digital_sketch/src/ui/widgets/overlay_items/toogle_view_button.dart';
import 'package:electric_digital_sketch/src/ui/widgets/overlay_items/toolbar/network_map_editor_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class NetworkEditorMapView extends StatefulWidget {
  const NetworkEditorMapView({
    super.key,
    required this.controller,
    required this.mapController,
    required this.onRecenter,
    required this.segmentHitNotifier,
    required this.locationGranted,
    required this.initialCenter,
    required this.onMapTap,
    required this.onNodeTap,
    required this.overlayItems,
    this.showCurrentPosition = true,
    this.onSave,
  });

  final NetworkEditorController controller;
  final MapController mapController;
  final LayerHitNotifier<EditorSegment> segmentHitNotifier;
  final bool locationGranted;
  final VoidCallback onRecenter;
  final bool showCurrentPosition;
  final LatLng initialCenter;
  final List<Widget> overlayItems;
  final TapCallback onMapTap;
  final Future<void> Function(EditorNode node) onNodeTap;
  final VoidCallback? onSave;

  @override
  State<NetworkEditorMapView> createState() => _NetworkEditorMapViewState();
}

class _NetworkEditorMapViewState extends State<NetworkEditorMapView> {

  final GlobalKey _mapCaptureKey = GlobalKey();
  final _snapshotService = NetworkEditorSnapshotService();

  Future<File?> openMapEditor() async {
    final originalFile = await _snapshotService.captureToCache(
      boundaryKey: _mapCaptureKey,
      fileName: 'map_before_edit.png',
    );

    if (!mounted) return null;

    final editedFile = await Navigator.of(context).push<File>(
      MaterialPageRoute(
        builder: (_) => NetworkImageEditorPage(
          sourceFile: originalFile,
        ),
      ),
    );

    return editedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _mapCaptureKey,
            child: FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                backgroundColor: widget.controller.backgroundView == BackgroundView.solidDark ? Colors.black : const Color(0xFF333333),
                initialCenter: widget.initialCenter,
                initialZoom: widget.controller.initialZoom,
                onTap: widget.onMapTap,
              ),
              children: [
                if (widget.controller.backgroundView == BackgroundView.map && widget.controller.baseTileLayer != null) widget.controller.baseTileLayer!,
                if (widget.controller.backgroundView == BackgroundView.solidDark) const ColoredBox(color: Colors.black),
                if (widget.locationGranted && widget.showCurrentPosition)
                  const CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: DefaultLocationMarker(),
                      markerSize: Size(22, 22),
                    ),
                  ),
                PolylineLayer<EditorSegment>(
                  polylines: widget.controller.buildPolylines(),
                  hitNotifier: widget.segmentHitNotifier,
                ),
                MarkerLayer(
                  markers: widget.controller.buildMarkers(
                    onTapNode: widget.onNodeTap,
                  ),
                ),
              ],
            ),
          ),
          ...widget.overlayItems,
          Positioned(
            bottom: 16,
            left: 12,
            child: ToogleViewButton(
              backgroundView: widget.controller.backgroundView,
              onTap: widget.controller.toggleDarkBackground,
            )
          ),
          Positioned(
            bottom: 16,
            right: 72,
            child: RecenterButton(onTap: widget.onRecenter)
          ),
          Positioned(
            bottom: 16,
            right: 128,
            child: NetworkImageEditorButtom(mapCaptureKey: _mapCaptureKey)
          )
        ],
      ),
      floatingActionButton: NetworkMapEditorToolbar(
        items: widget.controller.toolbarActions,
        controller: widget.controller,
        // onSave: onSave,
      ),
    );
  }
}