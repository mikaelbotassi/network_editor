import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_editor/src/domain/entities/editor_node.dart';
import 'package:network_editor/src/ui/styles/network_hub_layer_style.dart';
import 'package:network_editor/src/ui/widgets/node_marker_widget.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkHubFeatureLayer extends StatelessWidget {
  const NetworkHubFeatureLayer({
    super.key,
    required this.features,
    this.hitNotifier,
    this.onFeatureTap,
  });

  final List<hub.NetworkFeature> features;
  final LayerHitNotifier<hub.NetworkFeature>? hitNotifier;
  final ValueChanged<hub.NetworkFeature>? onFeatureTap;

  @override
  Widget build(BuildContext context) {
    final lines = <Polyline<hub.NetworkFeature>>[];
    final markers = <Marker>[];

    for (final feature in features) {
      switch (feature.geometry) {
        case final hub.NetworkLineGeometry geometry:
          if (geometry.coordinates.length < 2) continue;
          lines.add(
            Polyline(
              points: [
                for (final coordinate in geometry.coordinates)
                  LatLng(coordinate.latitude, coordinate.longitude),
              ],
              color: feature.layer.mapColor,
              strokeWidth: feature.layer.lineWidth,
              pattern: feature.layer.strokePattern,
              hitValue: feature,
            ),
          );
        case final hub.NetworkPointGeometry geometry:
          final node = EditorNode(
            id: '${feature.layer.code}_${feature.id}',
            latitude: geometry.coordinate.latitude,
            longitude: geometry.coordinate.longitude,
            icon: feature.layer.icon,
            color: feature.layer.mapColor,
            label: feature.title ?? feature.layer.label,
            properties: feature.properties,
          );

          markers.add(
            Marker(
              point: LatLng(
                geometry.coordinate.latitude,
                geometry.coordinate.longitude,
              ),
              width: 36,
              height: 36,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onFeatureTap?.call(feature),
                child: NodeMarkerWidget(
                  node: node,
                  selected: false,
                  iconSize: feature.layer.iconSize,
                ),
              ),
            ),
          );
      }
    }

    return Stack(
      children: [
        if (lines.isNotEmpty)
          PolylineLayer<hub.NetworkFeature>(
            polylines: lines,
            hitNotifier: hitNotifier,
          ),
        if (markers.isNotEmpty)
          MarkerLayer(
            markers: markers,
          ),
      ],
    );
  }
}
