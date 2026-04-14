import 'dart:async';

import 'package:network_editor/network_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AddPoleInteraction extends EditorInteractionHandler{

  @override
  FutureOr<NetworkInteractionResult> onMapTap(
    EditorInteractionContext context,
    BuildContext buildContext,
    TapPosition tapPosition,
    LatLng point
  ) {
    final style = NetworkEditorDefaultMarkerStyles.emerald;
    if(!buildContext.mounted) return SilentInteractionResult();
    context.controller.createNode(EditorNode(
      id: UniqueKey().toString(),
      latitude: point.latitude,
      longitude: point.longitude,
      color: style.fillColor,
      groupId: 'pole',
      svgPath: 'assets/icons/poste-terra.svg'
    ));
    return SilentInteractionResult();

  }


}