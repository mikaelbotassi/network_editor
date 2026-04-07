
import 'package:electric_digital_sketch/src/domain/entities/editor_node.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_segment.dart';

sealed class NetworkInteractionResult {
  const NetworkInteractionResult();
}

final class SilentInteractionResult extends NetworkInteractionResult {
  const SilentInteractionResult();
}

final class NodeTappedResult extends NetworkInteractionResult {
  final EditorNode node;

  const NodeTappedResult(this.node);
}

final class SegmentTappedResult extends NetworkInteractionResult {
  final EditorSegment segment;

  const SegmentTappedResult(this.segment);
}