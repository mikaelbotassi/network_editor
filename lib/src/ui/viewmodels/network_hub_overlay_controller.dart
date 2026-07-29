import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

class NetworkHubOverlayController extends ChangeNotifier {
  NetworkHubOverlayController({
    hub.SmreNetworkClient? client,
    Set<hub.NetworkLayer>? initialVisibleLayers,
    this.maximumTiles = 32,
    this.concurrency = 4,
  }) : _client = client ?? hub.SmreNetworkClient(),
       _visibleLayers = {
         ...?initialVisibleLayers,
         if (initialVisibleLayers == null) ...hub.NetworkLayer.values,
       };

  final hub.SmreNetworkClient _client;
  final int maximumTiles;
  final int concurrency;

  Set<hub.NetworkLayer> _visibleLayers;
  List<hub.NetworkFeature> _features = const [];
  LatLngBounds? _latestBounds;
  double _currentZoom = 0;
  Object? _error;
  bool? _hubAvailable;
  bool _loading = false;
  int _generation = 0;
  String? _loadedSignature;
  String? _pendingSignature;

  Set<hub.NetworkLayer> get visibleLayers => Set.unmodifiable(_visibleLayers);
  List<hub.NetworkFeature> get features => _features;
  double get currentZoom => _currentZoom;
  Object? get error => _error;
  bool? get hubAvailable => _hubAvailable;
  bool get loading => _loading;

  int get visibleFeatureCount => _features.length;

  Set<hub.NetworkLayer> get requestedLayers {
    final zoom = _queryZoom(_currentZoom);
    return {
      for (final layer in _visibleLayers)
        if (zoom >= layer.minimumZoom) layer,
    };
  }

  bool isLayerVisible(hub.NetworkLayer layer) => _visibleLayers.contains(layer);

  Future<void> setLayerVisible(hub.NetworkLayer layer, bool visible) async {
    final next = {..._visibleLayers};
    if (visible) {
      next.add(layer);
    } else {
      next.remove(layer);
    }
    if (setEquals(next, _visibleLayers)) return;

    _visibleLayers = next;
    notifyListeners();

    final bounds = _latestBounds;
    if (bounds != null) {
      await loadViewport(bounds: bounds, zoom: _currentZoom);
    }
  }

  Future<void> loadViewport({
    required LatLngBounds bounds,
    required double zoom,
    bool refresh = false,
  }) async {
    _latestBounds = bounds;
    _currentZoom = zoom;

    final queryZoom = _queryZoom(zoom);
    final layers = {
      for (final layer in _visibleLayers)
        if (queryZoom >= layer.minimumZoom) layer,
    };

    if (layers.isEmpty) {
      _generation++;
      _pendingSignature = null;
      _loadedSignature = null;
      _features = const [];
      _error = null;
      _loading = false;
      notifyListeners();
      return;
    }

    final networkBounds = hub.NetworkBounds(
      south: bounds.south,
      west: bounds.west,
      north: bounds.north,
      east: bounds.east,
    );
    final addresses = hub.NetworkTileMath.addressesForBounds(
      networkBounds,
      zoom: queryZoom,
      maximumTiles: maximumTiles,
    );
    final layerCodes = layers.map((layer) => layer.code).toList()..sort();
    final signature =
        '$queryZoom:${layerCodes.join(",")}:'
        '${addresses.map((address) => '${address.x}/${address.y}').join(",")}';

    if (!refresh &&
        (signature == _loadedSignature || signature == _pendingSignature)) {
      return;
    }

    final generation = ++_generation;
    _pendingSignature = signature;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final available = _hubAvailable == true
          ? true
          : await _client.isAvailable();
      if (generation != _generation) return;
      _hubAvailable = available;
      if (!available) {
        throw const hub.NetworkHubUnavailableException();
      }

      final requests = [
        for (final address in addresses)
          hub.NetworkTileRequest(address: address, layers: layers),
      ];
      final tiles = await _client.readTiles(
        requests,
        concurrency: concurrency,
        refresh: refresh,
      );
      if (generation != _generation) return;

      final byId = <String, hub.NetworkFeature>{};
      for (final tile in tiles) {
        for (final feature in tile.features) {
          byId['${feature.layer.code}/${feature.id}'] = feature;
        }
      }

      _features = byId.values.toList(growable: false);
      _loadedSignature = signature;
    } catch (error) {
      if (generation != _generation) return;
      if (kDebugMode) {
        debugPrint(
          'Falha ao carregar o viewport do SMRE Hub: $error'
          '${error is hub.NetworkHubException && error.cause != null ? '\nCausa: ${error.cause}' : ''}',
        );
      }
      _features = const [];
      _error = error;
    } finally {
      if (generation == _generation) {
        _pendingSignature = null;
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    final bounds = _latestBounds;
    if (bounds == null) return;
    await loadViewport(bounds: bounds, zoom: _currentZoom, refresh: true);
  }

  @override
  void dispose() {
    _generation++;
    super.dispose();
  }

  static int _queryZoom(double zoom) => zoom.floor().clamp(0, 22);
}
