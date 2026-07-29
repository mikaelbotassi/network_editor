import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_editor/src/ui/styles/network_hub_layer_style.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkHubFeatureLayer extends StatelessWidget {
  const NetworkHubFeatureLayer({
    super.key,
    required this.features,
    this.hitNotifier,
  });

  final List<hub.NetworkFeature> features;
  final LayerHitNotifier<hub.NetworkFeature>? hitNotifier;

  @override
  Widget build(BuildContext context) {
    final lines = <Polyline<hub.NetworkFeature>>[];
    final points = <CircleMarker<hub.NetworkFeature>>[];

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
              hitValue: feature,
            ),
          );
        case final hub.NetworkPointGeometry geometry:
          points.add(
            CircleMarker(
              point: LatLng(
                geometry.coordinate.latitude,
                geometry.coordinate.longitude,
              ),
              radius: feature.layer.pointRadius,
              color: feature.layer.mapColor,
              borderColor: const Color(0xFFFFFFFF),
              borderStrokeWidth: 1.2,
              hitValue: feature,
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
        if (points.isNotEmpty)
          CircleLayer<hub.NetworkFeature>(
            circles: points,
            hitNotifier: hitNotifier,
          ),
      ],
    );
  }
}
