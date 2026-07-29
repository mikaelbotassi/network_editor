import 'dart:async';

import 'package:network_editor/network_editor.dart';
import 'package:network_editor/src/domain/enums/network_view.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/network_image_editor_buttom.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/recenter_button.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/toogle_view_button.dart';
import 'package:network_editor/src/ui/widgets/overlay_items/toolbar/network_map_editor_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkEditorMapView extends StatefulWidget {
  const NetworkEditorMapView({
    super.key,
    required this.controller,
    required this.mapController,
    required this.onRecenter,
    required this.segmentHitNotifier,
    required this.locationGranted,
    required this.initialCenter,
    required this.onMapTap,
    required this.onNodeTap,
    required this.overlayItems,
    required this.showHubNetwork,
    this.initialVisibleNetworkLayers,
    this.networkClient,
    this.onNetworkFeatureTap,
    this.showCurrentPosition = true,
    this.onSave,
  });

  final NetworkEditorController controller;
  final MapController mapController;
  final LayerHitNotifier<EditorSegment> segmentHitNotifier;
  final bool locationGranted;
  final VoidCallback onRecenter;
  final bool showCurrentPosition;
  final LatLng initialCenter;
  final List<Widget> overlayItems;
  final bool showHubNetwork;
  final Set<hub.NetworkLayer>? initialVisibleNetworkLayers;
  final hub.SmreNetworkClient? networkClient;
  final ValueChanged<hub.NetworkFeature>? onNetworkFeatureTap;
  final TapCallback onMapTap;
  final Future<void> Function(EditorNode node) onNodeTap;
  final VoidCallback? onSave;

  @override
  State<NetworkEditorMapView> createState() => _NetworkEditorMapViewState();
}

class _NetworkEditorMapViewState extends State<NetworkEditorMapView> {
  final GlobalKey _mapCaptureKey = GlobalKey();
  final LayerHitNotifier<hub.NetworkFeature> _networkFeatureHitNotifier =
      ValueNotifier(null);
  late final NetworkHubOverlayController _networkOverlayController;
  Timer? _networkQueryDebounce;
  MapCamera? _latestCamera;

  @override
  void initState() {
    super.initState();
    _networkOverlayController = NetworkHubOverlayController(
      client: widget.networkClient,
      initialVisibleLayers: widget.initialVisibleNetworkLayers,
    )..addListener(_handleNetworkOverlayChanged);
    _networkFeatureHitNotifier.addListener(_handleNetworkFeatureHit);
  }

  @override
  void didUpdateWidget(covariant NetworkEditorMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    assert(
      identical(oldWidget.networkClient, widget.networkClient),
      'networkClient nao pode ser alterado durante a vida do mapa.',
    );

    if (!widget.showHubNetwork) {
      _networkQueryDebounce?.cancel();
    } else if (!oldWidget.showHubNetwork && _latestCamera != null) {
      _scheduleNetworkQuery(_latestCamera!, immediately: true);
    }
  }

  @override
  void dispose() {
    _networkQueryDebounce?.cancel();
    _networkFeatureHitNotifier.removeListener(_handleNetworkFeatureHit);
    _networkFeatureHitNotifier.dispose();
    _networkOverlayController.removeListener(_handleNetworkOverlayChanged);
    _networkOverlayController.dispose();
    super.dispose();
  }

  void _handleNetworkOverlayChanged() {
    if (mounted) setState(() {});
  }

  void _handleNetworkFeatureHit() {
    final hit = _networkFeatureHitNotifier.value;
    if (hit == null || hit.hitValues.isEmpty) return;
    widget.onNetworkFeatureTap?.call(hit.hitValues.first);
    _networkFeatureHitNotifier.value = null;
  }

  void _handleMapReady() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleNetworkQuery(widget.mapController.camera, immediately: true);
    });
  }

  void _handlePositionChanged(MapCamera camera, bool hasGesture) {
    _scheduleNetworkQuery(camera);
  }

  void _scheduleNetworkQuery(MapCamera camera, {bool immediately = false}) {
    _latestCamera = camera;
    if (!widget.showHubNetwork ||
        !camera.nonRotatedSize.width.isFinite ||
        !camera.nonRotatedSize.height.isFinite ||
        camera.nonRotatedSize.isEmpty) {
      return;
    }

    _networkQueryDebounce?.cancel();
    _networkQueryDebounce = Timer(
      immediately ? Duration.zero : const Duration(milliseconds: 180),
      () {
        if (!mounted || !widget.showHubNetwork) return;
        unawaited(
          _networkOverlayController.loadViewport(
            bounds: camera.visibleBounds,
            zoom: camera.zoom,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RepaintBoundary(
            key: _mapCaptureKey,
            child: FlutterMap(
              mapController: widget.mapController,
              options: MapOptions(
                backgroundColor:
                    widget.controller.backgroundView == BackgroundView.solidDark
                    ? Colors.black
                    : const Color(0xFF333333),
                initialCenter: widget.initialCenter,
                initialZoom: widget.controller.initialZoom,
                onTap: widget.onMapTap,
                onMapReady: _handleMapReady,
                onPositionChanged: _handlePositionChanged,
              ),
              children: [
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution('© OpenStreetMap contributors'),
                  ],
                ),
                if (widget.controller.backgroundView == BackgroundView.map &&
                    widget.controller.baseTileLayer != null)
                  widget.controller.baseTileLayer!,
                if (widget.controller.backgroundView ==
                    BackgroundView.solidDark)
                  const ColoredBox(color: Colors.black),
                if (widget.locationGranted && widget.showCurrentPosition)
                  const CurrentLocationLayer(
                    style: LocationMarkerStyle(
                      marker: DefaultLocationMarker(),
                      markerSize: Size(22, 22),
                    ),
                  ),
                if (widget.showHubNetwork)
                  NetworkHubFeatureLayer(
                    features: _networkOverlayController.features,
                    hitNotifier: widget.onNetworkFeatureTap == null
                        ? null
                        : _networkFeatureHitNotifier,
                  ),
                PolylineLayer<EditorSegment>(
                  polylines: widget.controller.buildPolylines(),
                  hitNotifier: widget.segmentHitNotifier,
                ),
                MarkerLayer(
                  markers: widget.controller.buildMarkers(
                    onTapNode: widget.onNodeTap,
                  ),
                ),
              ],
            ),
          ),
          ...widget.overlayItems,
          if (widget.showHubNetwork)
            Positioned(
              top: 12,
              right: 12,
              child: NetworkHubLayerControl(
                controller: _networkOverlayController,
              ),
            ),
          Positioned(
            bottom: 16,
            left: 12,
            child: ToogleViewButton(
              backgroundView: widget.controller.backgroundView,
              onTap: widget.controller.toggleDarkBackground,
            ),
          ),
          Positioned(
            bottom: 16,
            right: 72,
            child: RecenterButton(onTap: widget.onRecenter),
          ),
          Positioned(
            bottom: 16,
            right: 128,
            child: NetworkImageEditorButtom(mapCaptureKey: _mapCaptureKey),
          ),
        ],
      ),
      floatingActionButton: NetworkMapEditorToolbar(
        items: widget.controller.toolbarActions,
        controller: widget.controller,
        // onSave: onSave,
      ),
    );
  }
}
