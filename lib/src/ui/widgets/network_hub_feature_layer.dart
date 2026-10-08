import 'package:flutter/material.dart';
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
    final pointFeatures = <hub.NetworkFeature>[];

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
        case final hub.NetworkPointGeometry _:
          pointFeatures.add(feature);
      }
    }

    final groups = _groupPointFeatures(pointFeatures);
    final markers = <Marker>[];

    for (final group in groups) {
      final node = group.toEditorNode();
      final primaryFeature = group.primaryFeature;

      markers.add(
        Marker(
          point: group.coordinate,
          width: 38,
          height: 38,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onFeatureTap?.call(primaryFeature),
            child: NodeMarkerWidget(
              node: node,
              selected: false,
              iconSize: 16,
            ),
          ),
        ),
      );
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

  List<_PointFeatureGroup> _groupPointFeatures(List<hub.NetworkFeature> pointFeatures) {
    final groupsMap = <String, _PointFeatureGroup>{};

    for (final feature in pointFeatures) {
      final geom = feature.geometry as hub.NetworkPointGeometry;
      final coord = LatLng(geom.coordinate.latitude, geom.coordinate.longitude);
      final pontoScId = _extractPontoScId(feature);

      String groupKey;
      if (pontoScId != null) {
        groupKey = 'ponto_$pontoScId';
      } else {
        final latKey = (coord.latitude * 100000).round();
        final lngKey = (coord.longitude * 100000).round();
        groupKey = 'coord_${latKey}_$lngKey';
      }

      final existingGroup = groupsMap[groupKey];
      if (existingGroup == null) {
        groupsMap[groupKey] = _PointFeatureGroup(
          key: groupKey,
          coordinate: coord,
          features: [feature],
        );
      } else {
        existingGroup.features.add(feature);
      }
    }

    return groupsMap.values.toList(growable: false);
  }

  static String? _extractPontoScId(hub.NetworkFeature feature) {
    final props = feature.properties;
    final val = props['idPontoSc'] ??
        props['id_ponto_sc'] ??
        props['idPontoSC'] ??
        props['id_ponto'] ??
        props['pontoSc'] ??
        props['ponto_sc'];
    if (val != null && '$val'.isNotEmpty) {
      return '$val';
    }
    return null;
  }
}

class _PointFeatureGroup {
  _PointFeatureGroup({
    required this.key,
    required this.coordinate,
    required this.features,
  });

  final String key;
  final LatLng coordinate;
  final List<hub.NetworkFeature> features;

  hub.NetworkFeature get primaryFeature {
    final pole = features.cast<hub.NetworkFeature?>().firstWhere(
      (f) => f?.layer == hub.NetworkLayer.poste,
      orElse: () => null,
    );
    if (pole != null) return pole;
    return features.first;
  }

  EditorNode toEditorNode() {
    final primary = primaryFeature;
    final pole = features.cast<hub.NetworkFeature?>().firstWhere(
      (f) => f?.layer == hub.NetworkLayer.poste,
      orElse: () => null,
    );

    final icons = <IconData>[];
    final colors = <Color>[];
    final structuresList = <Map<String, dynamic>>[];

    for (final f in features) {
      icons.add(f.layer.icon);
      colors.add(f.layer.mapColor);
      structuresList.add({
        'id': f.id,
        'layer': f.layer.label,
        'layer_code': f.layer.code,
        'title': f.title ?? f.layer.label,
        'subtitle': f.subtitle,
        ...f.properties,
      });
    }

    final mainColor = pole != null ? pole.layer.mapColor : primary.layer.mapColor;
    final mainIcon = pole != null ? pole.layer.icon : primary.layer.icon;

    return EditorNode(
      id: key,
      latitude: coordinate.latitude,
      longitude: coordinate.longitude,
      icon: mainIcon,
      color: mainColor,
      label: primary.title ?? primary.layer.label,
      properties: {
        'structures': structuresList,
        'grouped_icons': icons,
        'grouped_colors': colors,
        'has_pole': pole != null,
        ...primary.properties,
      },
    );
  }
}
