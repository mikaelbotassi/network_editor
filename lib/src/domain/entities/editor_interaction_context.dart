import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_mode_key.dart';
import 'package:electric_digital_sketch/src/domain/entities/network_editor_state.dart';

/// =======================================================
/// INTERACTION CONTEXT
/// =======================================================

class EditorInteractionContext {
  final NetworkEditorController controller;
  final NetworkEditorState state;

  const EditorInteractionContext({
    required this.controller,
    required this.state,
  });

  EditorModeKey get mode => state.mode;
  NetworkEditorValue get value => state.value;

  String? get selectedNodeId => state.selectedNodeId;
  String? get selectedSegmentId => state.selectedSegmentId;
  String? get connectingFromNodeId => state.connectingFromNodeId;
}