import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_mode_key.dart';
import 'package:flutter/foundation.dart';

/// =======================================================
/// INTERNAL STATE
/// =======================================================

@immutable
class NetworkEditorState {
  final NetworkEditorValue value;
  final EditorMode mode;
  final String? selectedNodeId;
  final String? selectedSegmentId;
  final String? connectingFromNodeId;

  const NetworkEditorState({
    required this.value,
    required this.mode,
    this.selectedNodeId,
    this.selectedSegmentId,
    this.connectingFromNodeId,
  });

  List<EditorNode> get activeNodes =>
      value.nodes.where((e) => !e.isDeleted).toList(growable: false);

  List<EditorSegment> get activeSegments =>
      value.segments.where((e) => !e.isDeleted).toList(growable: false);

  NetworkEditorState copyWith({
    NetworkEditorValue? value,
    EditorMode? mode,
    String? selectedNodeId,
    bool clearSelectedNodeId = false,
    String? selectedSegmentId,
    bool clearSelectedSegmentId = false,
    String? connectingFromNodeId,
    bool clearConnectingFromNodeId = false,
  }) {
    return NetworkEditorState(
      value: value ?? this.value,
      mode: mode ?? this.mode,
      selectedNodeId: clearSelectedNodeId
          ? null
          : (selectedNodeId ?? this.selectedNodeId),
      selectedSegmentId: clearSelectedSegmentId
          ? null
          : (selectedSegmentId ?? this.selectedSegmentId),
      connectingFromNodeId: clearConnectingFromNodeId
          ? null
          : (connectingFromNodeId ?? this.connectingFromNodeId),
    );
  }
}