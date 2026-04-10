import 'dart:async';

import 'package:electric_digital_sketch/electric_digital_sketch.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_interaction_context.dart';
import 'package:electric_digital_sketch/src/domain/entities/editor_interaction_handler.dart';

/// =======================================================
/// BUILT-IN MODES
/// =======================================================

class ViewModeHandler extends EditorInteractionHandler {
  const ViewModeHandler();

  @override
  FutureOr<NetworkInteractionResult> onNodeTap(
      EditorInteractionContext context,
      EditorNode node,
      ) {
    context.controller.selectNode(node.id);
    return NodeTappedResult(node);
  }

  @override
  FutureOr<NetworkInteractionResult> onSegmentTap(
      EditorInteractionContext context,
      EditorSegment segment,
      ) {
    context.controller.selectSegment(segment.id);
    return SegmentTappedResult(segment);
  }
}