import 'package:electric_digital_sketch/src/domain/entities/editor_node.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_segment.dart';

class NetworkEditorValue {
  final List<EditorNode> nodes;
  final List<EditorSegment> segments;

  const NetworkEditorValue({
    this.nodes = const [],
    this.segments = const [],
  });

  NetworkEditorValue copyWith({
    List<EditorNode>? nodes,
    List<EditorSegment>? segments,
  }) {
    return NetworkEditorValue(
      nodes: nodes ?? this.nodes,
      segments: segments ?? this.segments,
    );
  }
}