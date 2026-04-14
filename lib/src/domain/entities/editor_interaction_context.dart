
import 'package:network_editor/src/domain/domain.dart';
import 'package:network_editor/src/ui/ui.dart';

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

  EditorMode get mode => state.mode;
  NetworkEditorValue get value => state.value;

  String? get selectedNodeId => state.selectedNodeId;
  String? get selectedSegmentId => state.selectedSegmentId;
  String? get connectingFromNodeId => state.connectingFromNodeId;
}