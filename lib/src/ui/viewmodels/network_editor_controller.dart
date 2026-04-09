import 'dart:async';

import 'package:electric_digital_sketch/src/domain/domain.dart';
import 'package:electric_digital_sketch/src/ui/widgets/node_marker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class NetworkEditorController extends ChangeNotifier {
  NetworkEditorController({
    required NetworkEditorValue initialValue,
    this.onMapTap,
    this.initialCenter = const LatLng(-19.5, -40.6),
    this.initialZoom = 16,
    this.baseTileLayer,
    this.showDarkBackground = false,
  }) : _originalValue = initialValue, _value = initialValue;

  final NetworkEditorValue _originalValue;
  NetworkEditorValue _value;
  final FutureOr<void> Function(TapPosition, LatLng)? onMapTap;

  final LatLng initialCenter;
  final double initialZoom;
  final TileLayer? baseTileLayer;
  final bool showDarkBackground;

  String _mode = 'view';
  String? selectedNodeId;
  String? selectedSegmentId;
  EditorNode? connectingFromNode;

  NetworkEditorValue get value => _value;

  List<EditorNode> get activeNodes =>
      _value.nodes.where((e) => !e.isDeleted).toList();

  List<EditorSegment> get activeSegments =>
      _value.segments.where((e) => !e.isDeleted).toList();

  set mode(String newMode) {
    _mode = newMode;
    notifyListeners();
  }

  String get mode => _mode;

  void cancelConnection() {
    connectingFromNode = null;
    notifyListeners();
  }

  NetworkInteractionResult handleNodeTap(EditorNode node) {
    switch (mode) {
      case 'view':
        selectedNodeId = node.id;
        notifyListeners();
        return NodeTappedResult(node);

      case 'delete':
        deleteNode(node.id);
        return const SilentInteractionResult();

      case 'move':
        selectedNodeId = node.id;
        notifyListeners();
        return NodeTappedResult(node);

      default:
        selectedNodeId = node.id;
        notifyListeners();
        return NodeTappedResult(node);
    }
  }

  NetworkInteractionResult handleSegmentTap(EditorSegment segment) {
    switch (mode) {
      case 'delete':
        deleteSegment(segment.id);
        return const SilentInteractionResult();

      default:
        selectedSegmentId = segment.id;
        notifyListeners();
        return SegmentTappedResult(segment);
    }
  }

  void moveNode(String nodeId, LatLng point) {
    final nodes = _value.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
      );
    }).toList();

    _value = _value.copyWith(nodes: nodes);
    notifyListeners();
  }

  void deleteNode(String nodeId) {
    final nodes = _value.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(isDeleted: true);
    }).toList();

    final segments = _value.segments.map((segment) {
      if (segment.fromNodeId == nodeId || segment.toNodeId == nodeId) {
        return segment.copyWith(isDeleted: true);
      }
      return segment;
    }).toList();

    _value = _value.copyWith(nodes: nodes, segments: segments);
    notifyListeners();
  }

  void deleteSegment(String segmentId) {
    final segments = _value.segments.map((segment) {
      if (segment.id != segmentId) return segment;
      return segment.copyWith(isDeleted: true);
    }).toList();

    _value = _value.copyWith(segments: segments);
    notifyListeners();
  }

  List<Marker> buildMarkers({
    required Future<void> Function(EditorNode node) onTapNode,
  }) {
    return activeNodes.map((node) {
      return Marker(
        point: LatLng(node.latitude, node.longitude),
        width: 42,
        height: 42,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onTapNode(node),
          child: NodeMarkerWidget(
            node: node,
            selected: node.id == selectedNodeId,
          ),
        ),
      );
    }).toList();
  }

  List<Polyline<Object>> buildPolylines({
    required Future<void> Function(EditorSegment segment) onSegmentTap,
  }) {
    return activeSegments.map((segment) {
      return Polyline(
        points: segment.points.map((e) => LatLng(e.latitude, e.longitude)).toList(),
        strokeWidth: segment.strokeWidth,
        color: segment.id == selectedSegmentId ? Colors.orange : segment.color,
        pattern: segment.pattern
        // onTap: () => onSegmentTap(segment),
      );
    }).toList();
  }

  NetworkEditorResult buildResult() {
    final originalNodesById = {for (final e in _originalValue.nodes) e.id: e};
    final originalSegmentsById = {for (final e in _originalValue.segments) e.id: e};

    final createdNodes = _value.nodes.where((e) => e.isNew && !e.isDeleted).toList();
    final deletedNodes = _value.nodes
        .where((e) => e.isDeleted && originalNodesById.containsKey(e.id))
        .toList();
    final updatedNodes = _value.nodes.where((e) {
      if (e.isNew || e.isDeleted) return false;
      final original = originalNodesById[e.id];
      if (original == null) return false;
      return original.latitude != e.latitude ||
          original.longitude != e.longitude ||
          original.label != e.label;
    }).toList();

    final createdSegments =
    _value.segments.where((e) => e.isNew && !e.isDeleted).toList();
    final deletedSegments = _value.segments
        .where((e) => e.isDeleted && originalSegmentsById.containsKey(e.id))
        .toList();
    final updatedSegments = _value.segments.where((e) {
      if (e.isNew || e.isDeleted) return false;
      final original = originalSegmentsById[e.id];
      if (original == null) return false;
      return !_sameCoords(original.points, e.points);
    }).toList();

    return NetworkEditorResult(
      currentValue: _value,
      createdNodes: createdNodes,
      updatedNodes: updatedNodes,
      deletedNodes: deletedNodes,
      createdSegments: createdSegments,
      updatedSegments: updatedSegments,
      deletedSegments: deletedSegments,
    );
  }

  bool _sameCoords(List<EditorCoordinate> a, List<EditorCoordinate> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude || a[i].longitude != b[i].longitude) {
        return false;
      }
    }
    return true;
  }

}