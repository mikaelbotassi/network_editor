import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_editor/src/domain/domain.dart';
import 'package:network_editor/src/plugins/location_permission_service.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_controller.dart';
import 'package:network_editor/src/ui/viewmodels/network_editor_location_coordinator.dart';
import 'package:network_editor/src/ui/widgets/network_editor_map_view.dart';

class NetworkEditorWidget extends StatefulWidget {
  const NetworkEditorWidget({
    super.key,
    required this.controller,
    this.initCentered = true,
    this.overlayItems = const [],
    this.onInteraction,
    this.onSave,
  });

  final bool initCentered;
  final NetworkEditorController controller;
  final List<Widget> overlayItems;
  final FutureOr<void> Function(NetworkInteractionResult result)? onInteraction;
  final ValueChanged<NetworkEditorResult>? onSave;

  @override
  State<NetworkEditorWidget> createState() => _NetworkEditorWidgetState();
}

class _NetworkEditorWidgetState extends State<NetworkEditorWidget> {
  final MapController _mapController = MapController();
  final LayerHitNotifier<EditorSegment> _segmentHitNotifier = ValueNotifier(null);

  late final NetworkEditorLocationCoordinator _locationCoordinator;

  NetworkEditorController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    _locationCoordinator = NetworkEditorLocationCoordinator(
      fallbackCenter: controller.initialCenter,
      initialZoom: controller.initialZoom,
      ensurePermission: LocationPermissionService.ensurePermission,
      onMoveToCurrentLocation: (center, zoom) {
        if (mounted) {
          _mapController.move(center, zoom);
        }
      },
    );

    _segmentHitNotifier.addListener(_handleSegmentHit);

    if (widget.initCentered) {
      _locationCoordinator.bootstrap();
    }
  }

  @override
  void dispose() {
    _segmentHitNotifier.removeListener(_handleSegmentHit);
    _segmentHitNotifier.dispose();
    _mapController.dispose();
    _locationCoordinator.dispose();
    super.dispose();
  }

  Future<void> _emitInteraction(
      Future<NetworkInteractionResult> Function(BuildContext) action,
      ) async {
    final result = await action(context);
    await widget.onInteraction?.call(result);
  }

  Future<void> _handleSegmentHit() async {
    final hit = _segmentHitNotifier.value;
    if (hit == null || hit.hitValues.isEmpty) return;

    final segment = hit.hitValues.first;

    await _emitInteraction((BuildContext context) => controller.handleSegmentTap(context, segment));

    _segmentHitNotifier.value = null;
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) {
    return _emitInteraction((BuildContext context) => controller.handleMapTap(context, tapPosition, point));
  }

  Future<void> _handleNodeTap(EditorNode node) {
    return _emitInteraction((BuildContext context) => controller.handleNodeTap(context, node));
  }

  void _handleSave() {
    widget.onSave?.call(controller.buildResult());
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([controller, _locationCoordinator]),
      builder: (context, _) {
        final locationState = _locationCoordinator.state;

        return NetworkEditorMapView(
          controller: controller,
          mapController: _mapController,
          onRecenter: _locationCoordinator.bootstrap,
          segmentHitNotifier: _segmentHitNotifier,
          locationGranted: locationState.granted,
          initialCenter: locationState.center ?? controller.initialCenter,
          onMapTap: _handleMapTap,
          onNodeTap: _handleNodeTap,
          overlayItems: widget.overlayItems,
          onSave: _handleSave,
        );
      },
    );
  }
}