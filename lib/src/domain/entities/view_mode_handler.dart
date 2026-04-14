import 'dart:async';

import 'package:electric_digital_sketch/src/domain/domain.dart';
import 'package:flutter/widgets.dart';

/// =======================================================
/// BUILT-IN MODES
/// =======================================================

class ViewModeHandler extends EditorInteractionHandler {
  const ViewModeHandler();

  @override
  FutureOr<NetworkInteractionResult> onNodeTap(
    EditorInteractionContext context,
    BuildContext buildContext,
    EditorNode node,
  ) {
    context.controller.selectNode(node.id);
    return NodeTappedResult(node);
  }

  @override
  FutureOr<NetworkInteractionResult> onSegmentTap(
    EditorInteractionContext context,
    BuildContext buildContext,
    EditorSegment segment,
  ) {
    context.controller.selectSegment(segment.id);
    return SegmentTappedResult(segment);
  }
}