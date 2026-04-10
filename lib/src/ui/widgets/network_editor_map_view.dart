import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/enums/network_view.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toogle_view_button.dart';
import 'package:electric_digital_sketch/src/ui/widgets/toolbar/network_map_editor_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';

class NetworkEditorMapView extends StatelessWidget {
  const NetworkEditorMapView({
    super.key,
    required this.controller,
    required this.mapController,
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
  final bool showCurrentPosition;
  final LatLng initialCenter;
  final List<Widget> overlayItems;
  final TapCallback onMapTap;
  final Future<void> Function(EditorNode node) onNodeTap;
  final VoidCallback? onSave;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              backgroundColor: controller.backgroundView == BackgroundView.solidDark ? Colors.black : const Color(0xFF333333),
              initialCenter: initialCenter,
              initialZoom: controller.initialZoom,
              onTap: onMapTap,
            ),
            children: [
              if (controller.backgroundView == BackgroundView.map && controller.baseTileLayer != null) controller.baseTileLayer!,
              if (controller.backgroundView == BackgroundView.solidDark) const ColoredBox(color: Colors.black),
              if (locationGranted && showCurrentPosition)
                const CurrentLocationLayer(
                  style: LocationMarkerStyle(
                    marker: DefaultLocationMarker(),
                    markerSize: Size(22, 22),
                  ),
                ),
              PolylineLayer<EditorSegment>(
                polylines: controller.buildPolylines(),
                hitNotifier: segmentHitNotifier,
              ),
              MarkerLayer(
                markers: controller.buildMarkers(
                  onTapNode: onNodeTap,
                ),
              ),
            ],
          ),
          ...overlayItems,
          Positioned(
            bottom: 12,
            left: 12,
            child: ToogleViewButton(
              backgroundView: controller.backgroundView,
              onTap: controller.toggleDarkBackground,
            )
          )
        ],
      ),
      floatingActionButton: NetworkMapEditorToolbar(
        controller: controller,
        // onSave: onSave,
      ),
    );
  }
}