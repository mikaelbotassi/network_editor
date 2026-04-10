import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class NetworkEditorLocationState {
  const NetworkEditorLocationState({
    required this.ready,
    required this.granted,
    required this.center,
  });

  final bool ready;
  final bool granted;
  final LatLng? center;

  NetworkEditorLocationState copyWith({
    bool? ready,
    bool? granted,
    LatLng? center,
  }) {
    return NetworkEditorLocationState(
      ready: ready ?? this.ready,
      granted: granted ?? this.granted,
      center: center ?? this.center,
    );
  }

  factory NetworkEditorLocationState.initial(LatLng fallback) {
    return NetworkEditorLocationState(
      ready: false,
      granted: false,
      center: fallback,
    );
  }
}

class NetworkEditorLocationCoordinator extends ChangeNotifier {
  NetworkEditorLocationCoordinator({
    required this.fallbackCenter,
    required this.initialZoom,
    required this.onMoveToCurrentLocation,
    required this.ensurePermission,
  }) : _state = NetworkEditorLocationState.initial(fallbackCenter);

  final LatLng fallbackCenter;
  final double initialZoom;
  final Future<bool> Function() ensurePermission;
  final void Function(LatLng center, double zoom) onMoveToCurrentLocation;

  NetworkEditorLocationState _state;
  NetworkEditorLocationState get state => _state;

  Future<void> bootstrap() async {
    final granted = await ensurePermission();

    if (!granted) {
      _state = _state.copyWith(
        granted: false,
        ready: true,
        center: fallbackCenter,
      );
      notifyListeners();
      return;
    }

    _state = _state.copyWith(granted: true);
    notifyListeners();

    final lastKnown = await Geolocator.getLastKnownPosition();

    if (lastKnown != null) {
      _state = _state.copyWith(
        center: LatLng(lastKnown.latitude, lastKnown.longitude),
        ready: true,
      );
      notifyListeners();
    }

    try {
      final current = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final currentLatLng = LatLng(current.latitude, current.longitude);

      if (_state.center == null) {
        _state = _state.copyWith(
          center: currentLatLng,
          ready: true,
        );
        notifyListeners();
      } else {
        onMoveToCurrentLocation(currentLatLng, initialZoom);
      }
    } catch (_) {
      _state = _state.copyWith(
        center: _state.center ?? fallbackCenter,
        ready: true,
      );
      notifyListeners();
    }
  }
}