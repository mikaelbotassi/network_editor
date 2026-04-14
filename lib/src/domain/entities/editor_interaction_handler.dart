import 'dart:async';

import 'package:electric_digital_sketch/src/domain/entities/entities.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// =======================================================
/// INTERACTION HANDLER CONTRACT
/// =======================================================

abstract class EditorInteractionHandler {
  const EditorInteractionHandler();

  FutureOr<NetworkInteractionResult> onMapTap(
    EditorInteractionContext context,
    BuildContext buildContext,
    TapPosition tapPosition,
    LatLng point,
  ) {
    return const SilentInteractionResult();
  }

  FutureOr<NetworkInteractionResult> onNodeTap(EditorInteractionContext context, BuildContext buildContext, EditorNode node) {
    context.controller.selectNode(node.id);
    return NodeTappedResult(node);
  }

  FutureOr<NetworkInteractionResult> onSegmentTap(EditorInteractionContext context, BuildContext buildContext, EditorSegment segment) {
    context.controller.selectSegment(segment.id);
    return SegmentTappedResult(segment);
  }
}

class DeleteModeHandler extends EditorInteractionHandler {
  const DeleteModeHandler();

  @override
  FutureOr<NetworkInteractionResult> onNodeTap(EditorInteractionContext context, BuildContext buildContext, EditorNode node) {
    context.controller.deleteNode(node.id);
    return const SilentInteractionResult();
  }

  @override
  FutureOr<NetworkInteractionResult> onSegmentTap(EditorInteractionContext context, BuildContext buildContext, EditorSegment segment){
    context.controller.deleteSegment(segment.id);
    return const SilentInteractionResult();
  }
}

class MoveModeHandler extends EditorInteractionHandler {
  const MoveModeHandler();

  @override
  FutureOr<NetworkInteractionResult> onNodeTap(EditorInteractionContext context, BuildContext buildContext, EditorNode node) {
    context.controller.selectNode(node.id);
    return NodeTappedResult(node);
  }

  @override
  FutureOr<NetworkInteractionResult> onMapTap(EditorInteractionContext context, BuildContext buildContext, TapPosition tapPosition, LatLng point) {
    context.controller.moveNode(context.selectedNodeId!, point);
    return const SilentInteractionResult();
  }

}

class ConnectModeHandler extends EditorInteractionHandler {
  const ConnectModeHandler();

  @override
  FutureOr<NetworkInteractionResult> onNodeTap(EditorInteractionContext context, BuildContext buildContext, EditorNode node) {
    final fromNodeId = context.connectingFromNodeId;

    if (fromNodeId == null) {
      context.controller.startConnection(node.id);
      context.controller.selectNode(node.id);
      return NodeTappedResult(node);
    }

    if (fromNodeId == node.id) {
      context.controller.cancelConnection();
      context.controller.selectNode(node.id);
      return NodeTappedResult(node);
    }

    context.controller.createSegment(fromNodeId, node.id);
    context.controller.cancelConnection();
    context.controller.selectNode(node.id);

    return NodeTappedResult(node);
  }
}