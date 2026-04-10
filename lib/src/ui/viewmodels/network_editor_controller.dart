import 'dart:async';

import 'package:electric_digital_sketch/src/domain/domain.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_interaction_context.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_interaction_handler.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_mode_key.dart';
import 'package:electric_digital_sketch/src/domain/entities/network_editor_state.dart';
import 'package:electric_digital_sketch/src/domain/entities/view_mode_handler.dart';
import 'package:electric_digital_sketch/src/domain/enums/network_view.dart';
import 'package:electric_digital_sketch/src/ui/widgets/node_marker_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// =======================================================
/// CONTROLLER
/// =======================================================

class NetworkEditorController extends ChangeNotifier {
  NetworkEditorController({
    required NetworkEditorValue initialValue,
    this.initialCenter = const LatLng(-19.5, -40.6),
    this.initialZoom = 16,
    this.baseTileLayer,
    BackgroundView backgroundView = BackgroundView.map,
    Map<EditorModeKey, EditorInteractionHandler>? customModes,
  })  : _originalValue = initialValue, _backgroundView = backgroundView,
  _state = NetworkEditorState(value: initialValue, mode: EditorModeKey.view) {
    _handlers = {
      EditorModeKey.view: const ViewModeHandler(),
      EditorModeKey.move: const MoveModeHandler(),
      EditorModeKey.delete: const DeleteModeHandler(),
      EditorModeKey.connect: const ConnectModeHandler(),
      ...?customModes,
    };
  }

  final NetworkEditorValue _originalValue;
  final LatLng initialCenter;
  final double initialZoom;
  final TileLayer? baseTileLayer;
  BackgroundView _backgroundView;
  BackgroundView get backgroundView => _backgroundView;
  void setBackground(BackgroundView value) {
    if (_backgroundView == value) return;
    _backgroundView = value;
    notifyListeners();
  }

  void toggleDarkBackground() {
    setBackground(_backgroundView == BackgroundView.map ? BackgroundView.solidDark : BackgroundView.map);
  }

  late final Map<EditorModeKey, EditorInteractionHandler> _handlers;

  NetworkEditorState _state;

  NetworkEditorState get state => _state;
  NetworkEditorValue get value => _state.value;
  EditorModeKey get mode => _state.mode;

  String? get selectedNodeId => _state.selectedNodeId;
  String? get selectedSegmentId => _state.selectedSegmentId;
  String? get connectingFromNodeId => _state.connectingFromNodeId;

  List<EditorNode> get activeNodes => _state.activeNodes;
  List<EditorSegment> get activeSegments => _state.activeSegments;

  void registerMode(EditorModeKey key, EditorInteractionHandler handler) {
    _handlers[key] = handler;
  }

  void setMode(EditorModeKey mode) {
    if (_state.mode == mode) return;

    if (!_handlers.containsKey(mode)) {
      throw StateError(
        'Editor mode "${mode.value}" is not registered.',
      );
    }

    _updateState(
      _state.copyWith(
        mode: mode,
        clearSelectedSegmentId: true,
        clearConnectingFromNodeId: true,
      ),
    );
  }

  void cancelConnection() {
    if (_state.connectingFromNodeId == null) return;
    _updateState(_state.copyWith(clearConnectingFromNodeId: true));
  }

  void startConnection(String nodeId) {
    _updateState(_state.copyWith(connectingFromNodeId: nodeId));
  }

  void selectNode(String nodeId) {
    _updateState(
      _state.copyWith(
        selectedNodeId: nodeId,
        clearSelectedSegmentId: true,
      ),
    );
  }

  void selectSegment(String segmentId) {
    _updateState(
      _state.copyWith(
        selectedSegmentId: segmentId,
        clearSelectedNodeId: true,
      ),
    );
  }

  Future<NetworkInteractionResult> handleMapTap(
      TapPosition tapPosition,
      LatLng point,
      ) async {
    final handler = _resolveHandler();
    return await Future.value(
      handler.onMapTap(_context, tapPosition, point),
    );
  }

  Future<NetworkInteractionResult> handleNodeTap(EditorNode node) async {
    final handler = _resolveHandler();
    return await Future.value(
      handler.onNodeTap(_context, node),
    );
  }

  Future<NetworkInteractionResult> handleSegmentTap(EditorSegment segment) async {
    final handler = _resolveHandler();
    return await Future.value(
      handler.onSegmentTap(_context, segment),
    );
  }

  void moveNode(String nodeId, LatLng point) {
    final nodes = value.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(
        latitude: point.latitude,
        longitude: point.longitude,
      );
    }).toList(growable: false);

    _replaceValue(value.copyWith(nodes: nodes));
  }

  void deleteNode(String nodeId) {
    final nodes = value.nodes.map((node) {
      if (node.id != nodeId) return node;
      return node.copyWith(isDeleted: true);
    }).toList(growable: false);

    final segments = value.segments.map((segment) {
      if (segment.fromNodeId == nodeId || segment.toNodeId == nodeId) {
        return segment.copyWith(isDeleted: true);
      }
      return segment;
    }).toList(growable: false);

    _replaceValue(value.copyWith(nodes: nodes, segments: segments));
  }

  void deleteSegment(String segmentId) {
    final segments = value.segments.map((segment) {
      if (segment.id != segmentId) return segment;
      return segment.copyWith(isDeleted: true);
    }).toList(growable: false);

    _replaceValue(value.copyWith(segments: segments));
  }

  void createSegment(String fromNodeId, String toNodeId) {
    final fromNode = value.nodes.where((e) => e.id == fromNodeId).firstOrNull;
    final toNode = value.nodes.where((e) => e.id == toNodeId).firstOrNull;

    if (fromNode == null || toNode == null) return;

    final newSegment = EditorSegment(
      id: UniqueKey().toString(),
      fromNodeId: fromNodeId,
      toNodeId: toNodeId,
      points: [
        EditorCoordinate(
          latitude: fromNode.latitude,
          longitude: fromNode.longitude,
        ),
        EditorCoordinate(
          latitude: toNode.latitude,
          longitude: toNode.longitude,
        ),
      ],
      isNew: true,
    );

    final segments = [...value.segments, newSegment];
    _replaceValue(value.copyWith(segments: segments));
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
    }).toList(growable: false);
  }

  List<Polyline<EditorSegment>> buildPolylines() {
    return activeSegments.map((segment) {
      return Polyline<EditorSegment>(
        points: segment.points
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList(growable: false),
        strokeWidth: segment.strokeWidth,
        color: segment.id == selectedSegmentId ? Colors.orange : segment.color,
        pattern: segment.pattern,
        hitValue: segment,
      );
    }).toList(growable: false);
  }

  NetworkEditorResult buildResult() {
    final originalNodesById = {
      for (final e in _originalValue.nodes) e.id: e,
    };
    final originalSegmentsById = {
      for (final e in _originalValue.segments) e.id: e,
    };

    final createdNodes =
    value.nodes.where((e) => e.isNew && !e.isDeleted).toList(growable: false);

    final deletedNodes = value.nodes
        .where((e) => e.isDeleted && originalNodesById.containsKey(e.id))
        .toList(growable: false);

    final updatedNodes = value.nodes.where((e) {
      if (e.isNew || e.isDeleted) return false;
      final original = originalNodesById[e.id];
      if (original == null) return false;

      return original.latitude != e.latitude ||
          original.longitude != e.longitude ||
          original.label != e.label;
    }).toList(growable: false);

    final createdSegments =
    value.segments.where((e) => e.isNew && !e.isDeleted).toList(growable: false);

    final deletedSegments = value.segments
        .where((e) => e.isDeleted && originalSegmentsById.containsKey(e.id))
        .toList(growable: false);

    final updatedSegments = value.segments.where((e) {
      if (e.isNew || e.isDeleted) return false;
      final original = originalSegmentsById[e.id];
      if (original == null) return false;

      return !_sameCoords(original.points, e.points);
    }).toList(growable: false);

    return NetworkEditorResult(
      currentValue: value,
      createdNodes: createdNodes,
      updatedNodes: updatedNodes,
      deletedNodes: deletedNodes,
      createdSegments: createdSegments,
      updatedSegments: updatedSegments,
      deletedSegments: deletedSegments,
    );
  }

  EditorInteractionHandler _resolveHandler() {
    final handler = _handlers[_state.mode];
    if (handler == null) {
      throw StateError('No interaction handler registered for mode ${_state.mode.value}.');
    }
    return handler;
  }

  EditorInteractionContext get _context => EditorInteractionContext(
    controller: this,
    state: _state,
  );

  void _replaceValue(NetworkEditorValue newValue) {
    _updateState(_state.copyWith(value: newValue));
  }

  void _updateState(NetworkEditorState newState) {
    _state = newState;
    notifyListeners();
  }

  bool _sameCoords(List<EditorCoordinate> a, List<EditorCoordinate> b) {
    if (a.length != b.length) return false;

    for (var i = 0; i < a.length; i++) {
      if (a[i].latitude != b[i].latitude ||
          a[i].longitude != b[i].longitude) {
        return false;
      }
    }

    return true;
  }
}