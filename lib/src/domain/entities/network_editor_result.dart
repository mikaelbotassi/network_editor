import 'package:network_editor/src/domain/entities/editor_node.dart';
import 'package:network_editor/src/domain/entities/editor_segment.dart';
import 'package:network_editor/src/domain/entities/network_editor_value.dart';

class NetworkEditorResult {
  final NetworkEditorValue currentValue;
  final List<EditorNode> createdNodes;
  final List<EditorNode> updatedNodes;
  final List<EditorNode> deletedNodes;
  final List<EditorSegment> createdSegments;
  final List<EditorSegment> updatedSegments;
  final List<EditorSegment> deletedSegments;

  const NetworkEditorResult({
    required this.currentValue,
    this.createdNodes = const [],
    this.updatedNodes = const [],
    this.deletedNodes = const [],
    this.createdSegments = const [],
    this.updatedSegments = const [],
    this.deletedSegments = const [],
  });
}