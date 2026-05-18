import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:network_editor/network_editor.dart';

enum _CoordinateInputMode { geographic, utm }

class CoordsInput extends StatefulWidget {
  const CoordsInput({
    this.initialCoordinate,
    this.onChanged,
    super.key,
  });

  final EditorCoordinate? initialCoordinate;
  final ValueChanged<EditorCoordinate?>? onChanged;

  @override
  State<CoordsInput> createState() => _CoordsInputState();
}

class _CoordsInputState extends State<CoordsInput> {
  late final TextEditingController _firstController;
  late final TextEditingController _secondController;
  EditorCoordinate? _coordinate;
  _UtmCoordinate? _utmCoordinate;
  _CoordinateInputMode _mode = _CoordinateInputMode.geographic;
  bool _isSyncing = false;
  bool _isLoadingLocation = false;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController();
    _secondController = TextEditingController();
    _applyCoordinate(widget.initialCoordinate, notify: false);
  }

  @override
  void didUpdateWidget(covariant CoordsInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialCoordinate != widget.initialCoordinate) {
      _applyCoordinate(widget.initialCoordinate, notify: false);
    }
  }

  @override
  void dispose() {
    _firstController.dispose();
    _secondController.dispose();
    super.dispose();
  }

  void _applyCoordinate(
    EditorCoordinate? coordinate, {
    bool notify = true,
  }) {
    _coordinate = coordinate;
    _utmCoordinate = coordinate == null ? null : _CoordinateConverter.toUtm(coordinate);
    _syncControllers();
    if (notify) {
      widget.onChanged?.call(coordinate);
    }
  }

  void _syncControllers() {
    _isSyncing = true;
    if (_coordinate == null || (_mode == _CoordinateInputMode.utm && _utmCoordinate == null)) {
      _firstController.clear();
      _secondController.clear();
      _isSyncing = false;
      return;
    }

    if (_mode == _CoordinateInputMode.geographic) {
      _firstController.text = _formatDecimal(_coordinate!.latitude);
      _secondController.text = _formatDecimal(_coordinate!.longitude);
    } else {
      _firstController.text = _formatDecimal(_utmCoordinate!.easting, fractionDigits: 2);
      _secondController.text = _formatDecimal(_utmCoordinate!.northing, fractionDigits: 2);
    }
    _isSyncing = false;
  }

  void _toggleMode(_CoordinateInputMode mode) {
    if (_mode == mode) return;
    setState(() {
      _mode = mode;
      _syncControllers();
    });
  }

  void _handleFirstChanged(String value) {
    if (_isSyncing) return;
    _updateCoordinate(
      first: double.tryParse(value.replaceAll(',', '.')),
      second: double.tryParse(_secondController.text.replaceAll(',', '.')),
    );
  }

  void _handleSecondChanged(String value) {
    if (_isSyncing) return;
    _updateCoordinate(
      first: double.tryParse(_firstController.text.replaceAll(',', '.')),
      second: double.tryParse(value.replaceAll(',', '.')),
    );
  }

  void _updateCoordinate({double? first, double? second}) {
    if ((first == null || second == null) && _firstController.text.isEmpty && _secondController.text.isEmpty) {
      setState(() {
        _statusMessage = null;
        _applyCoordinate(null, notify: false);
      });
      widget.onChanged?.call(null);
      return;
    }

    if (first == null || second == null) return;

    if (_mode == _CoordinateInputMode.geographic) {
      if (first < -90 || first > 90 || second < -180 || second > 180) return;
      final nextCoordinate = EditorCoordinate(latitude: first, longitude: second);
      setState(() {
        _statusMessage = null;
        _applyCoordinate(nextCoordinate, notify: false);
      });
      widget.onChanged?.call(nextCoordinate);
      return;
    }

    final currentUtm = _utmCoordinate;
    if (currentUtm == null || first <= 0 || second <= 0) return;
    final nextCoordinate = _CoordinateConverter.fromUtm(
      easting: first,
      northing: second,
      zoneNumber: currentUtm.zoneNumber,
      northernHemisphere: currentUtm.northernHemisphere,
    );
    setState(() {
      _statusMessage = null;
      _utmCoordinate = currentUtm.copyWith(easting: first, northing: second);
      _coordinate = nextCoordinate;
    });
    widget.onChanged?.call(nextCoordinate);
  }

  Future<void> _fillWithCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _statusMessage = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!mounted) return;
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = 'Ative o servico de localizacao para continuar.';
          _isLoadingLocation = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (!mounted) return;
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (!mounted) return;
      }

      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'Permissao de localizacao negada.';
          _isLoadingLocation = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
        ),
      );
      if (!mounted) return;

      final coordinate = EditorCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      setState(() {
        _statusMessage = 'Precisao estimada: ${position.accuracy.toStringAsFixed(1)} m';
        _isLoadingLocation = false;
        _applyCoordinate(coordinate, notify: false);
      });
      widget.onChanged?.call(coordinate);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _statusMessage = 'Nao foi possivel obter a localizacao atual.';
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        spacing: 12,
        children: [
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: SegmentedButton<_CoordinateInputMode>(
                  segments: const [
                    ButtonSegment(
                      value: _CoordinateInputMode.geographic,
                      label: Text('Lat / Long'),
                      icon: Icon(Icons.public),
                    ),
                    ButtonSegment(
                      value: _CoordinateInputMode.utm,
                      label: Text('UTM X / Y'),
                      icon: Icon(Icons.grid_on),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (selection) => _toggleMode(selection.first),
                ),
              ),
              FilledButton.icon(
                onPressed: _isLoadingLocation ? null : _fillWithCurrentLocation,
                icon: _isLoadingLocation
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : const Icon(Icons.my_location),
                label: const Text('Local atual'),
              ),
            ],
          ),
          if (_mode == _CoordinateInputMode.utm)
            Text(
              _utmCoordinate == null
                  ? 'Zona UTM sera definida quando houver coordenada.'
                  : 'Zona UTM ${_utmCoordinate!.zoneNumber}${_utmCoordinate!.zoneLetter}',
              style: theme.textTheme.labelMedium,
            ),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: TextField(
                  controller: _firstController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: _handleFirstChanged,
                  decoration: InputDecoration(
                    labelText: _mode == _CoordinateInputMode.geographic ? 'Latitude' : 'UTM X',
                    hintText: _mode == _CoordinateInputMode.geographic ? '-19.535600' : '326230.15',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _secondController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  onChanged: _handleSecondChanged,
                  decoration: InputDecoration(
                    labelText: _mode == _CoordinateInputMode.geographic ? 'Longitude' : 'UTM Y',
                    hintText: _mode == _CoordinateInputMode.geographic ? '-40.630600' : '7838581.22',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          if (_statusMessage != null)
            Text(
              _statusMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }
}

String _formatDecimal(double value, {int fractionDigits = 6}) {
  return value.toStringAsFixed(fractionDigits);
}

class _UtmCoordinate {
  const _UtmCoordinate({
    required this.easting,
    required this.northing,
    required this.zoneNumber,
    required this.zoneLetter,
    required this.northernHemisphere,
  });

  final double easting;
  final double northing;
  final int zoneNumber;
  final String zoneLetter;
  final bool northernHemisphere;

  _UtmCoordinate copyWith({
    double? easting,
    double? northing,
    int? zoneNumber,
    String? zoneLetter,
    bool? northernHemisphere,
  }) {
    return _UtmCoordinate(
      easting: easting ?? this.easting,
      northing: northing ?? this.northing,
      zoneNumber: zoneNumber ?? this.zoneNumber,
      zoneLetter: zoneLetter ?? this.zoneLetter,
      northernHemisphere: northernHemisphere ?? this.northernHemisphere,
    );
  }
}

class _CoordinateConverter {
  static const double _equatorialRadius = 6378137.0;
  static const double _eccentricitySquared = 0.00669438;
  static const double _scaleFactor = 0.9996;

  static _UtmCoordinate toUtm(EditorCoordinate coordinate) {
    final latitude = coordinate.latitude;
    final longitude = coordinate.longitude;
    final zoneNumber = ((longitude + 180) / 6).floor() + 1;
    final zoneLetter = _latitudeToZoneLetter(latitude);
    final longitudeOrigin = (zoneNumber - 1) * 6 - 180 + 3;
    final latitudeRad = _degreesToRadians(latitude);
    final longitudeRad = _degreesToRadians(longitude);
    final longitudeOriginRad = _degreesToRadians(longitudeOrigin.toDouble());
    final eccPrimeSquared = _eccentricitySquared / (1 - _eccentricitySquared);

    final sinLatitude = math.sin(latitudeRad);
    final cosLatitude = math.cos(latitudeRad);
    final tanLatitude = math.tan(latitudeRad);

    final n = _equatorialRadius / math.sqrt(1 - _eccentricitySquared * sinLatitude * sinLatitude);
    final t = tanLatitude * tanLatitude;
    final c = eccPrimeSquared * cosLatitude * cosLatitude;
    final a = cosLatitude * (longitudeRad - longitudeOriginRad);

    final m = _equatorialRadius *
        ((1 -
                    _eccentricitySquared / 4 -
                    3 * _eccentricitySquared * _eccentricitySquared / 64 -
                    5 * _pow(_eccentricitySquared, 3) / 256) *
                latitudeRad -
            (3 * _eccentricitySquared / 8 +
                    3 * _eccentricitySquared * _eccentricitySquared / 32 +
                    45 * _pow(_eccentricitySquared, 3) / 1024) *
                math.sin(2 * latitudeRad) +
            (15 * _eccentricitySquared * _eccentricitySquared / 256 +
                    45 * _pow(_eccentricitySquared, 3) / 1024) *
                math.sin(4 * latitudeRad) -
            (35 * _pow(_eccentricitySquared, 3) / 3072) * math.sin(6 * latitudeRad));

    final easting = _scaleFactor *
            n *
            (a +
                (1 - t + c) * _pow(a, 3) / 6 +
                (5 - 18 * t + t * t + 72 * c - 58 * eccPrimeSquared) * _pow(a, 5) / 120) +
        500000.0;

    var northing = _scaleFactor *
        (m +
            n *
                tanLatitude *
                (a * a / 2 +
                    (5 - t + 9 * c + 4 * c * c) * _pow(a, 4) / 24 +
                    (61 - 58 * t + t * t + 600 * c - 330 * eccPrimeSquared) * _pow(a, 6) / 720));

    final northernHemisphere = latitude >= 0;
    if (!northernHemisphere) {
      northing += 10000000.0;
    }

    return _UtmCoordinate(
      easting: easting,
      northing: northing,
      zoneNumber: zoneNumber,
      zoneLetter: zoneLetter,
      northernHemisphere: northernHemisphere,
    );
  }

  static EditorCoordinate fromUtm({
    required double easting,
    required double northing,
    required int zoneNumber,
    required bool northernHemisphere,
  }) {
    var adjustedNorthing = northing;
    if (!northernHemisphere) {
      adjustedNorthing -= 10000000.0;
    }

    final x = easting - 500000.0;
    final y = adjustedNorthing;
    final longitudeOrigin = (zoneNumber - 1) * 6 - 180 + 3;
    final eccPrimeSquared = _eccentricitySquared / (1 - _eccentricitySquared);
    final m = y / _scaleFactor;
    final mu = m /
        (_equatorialRadius *
            (1 -
                _eccentricitySquared / 4 -
                3 * _eccentricitySquared * _eccentricitySquared / 64 -
                5 * _pow(_eccentricitySquared, 3) / 256));

    final e1 = (1 - math.sqrt(1 - _eccentricitySquared)) / (1 + math.sqrt(1 - _eccentricitySquared));

    final phi1Rad = mu +
        (3 * e1 / 2 - 27 * _pow(e1, 3) / 32) * math.sin(2 * mu) +
        (21 * e1 * e1 / 16 - 55 * _pow(e1, 4) / 32) * math.sin(4 * mu) +
        (151 * _pow(e1, 3) / 96) * math.sin(6 * mu) +
        (1097 * _pow(e1, 4) / 512) * math.sin(8 * mu);

    final sinPhi1 = math.sin(phi1Rad);
    final cosPhi1 = math.cos(phi1Rad);
    final tanPhi1 = math.tan(phi1Rad);

    final n1 = _equatorialRadius / math.sqrt(1 - _eccentricitySquared * sinPhi1 * sinPhi1);
    final t1 = tanPhi1 * tanPhi1;
    final c1 = eccPrimeSquared * cosPhi1 * cosPhi1;
    final r1 = _equatorialRadius * (1 - _eccentricitySquared) /
        _pow(1 - _eccentricitySquared * sinPhi1 * sinPhi1, 1.5);
    final d = x / (n1 * _scaleFactor);

    final latitude = phi1Rad -
        (n1 * tanPhi1 / r1) *
            (d * d / 2 -
                (5 + 3 * t1 + 10 * c1 - 4 * c1 * c1 - 9 * eccPrimeSquared) * _pow(d, 4) / 24 +
                (61 + 90 * t1 + 298 * c1 + 45 * t1 * t1 - 252 * eccPrimeSquared - 3 * c1 * c1) *
                    _pow(d, 6) /
                    720);

    final longitude = _degreesToRadians(longitudeOrigin.toDouble()) +
        (d -
                (1 + 2 * t1 + c1) * _pow(d, 3) / 6 +
                (5 - 2 * c1 + 28 * t1 - 3 * c1 * c1 + 8 * eccPrimeSquared + 24 * t1 * t1) *
                    _pow(d, 5) /
                    120) /
            cosPhi1;

    return EditorCoordinate(
      latitude: _radiansToDegrees(latitude),
      longitude: _radiansToDegrees(longitude),
    );
  }

  static double _degreesToRadians(double degrees) => degrees * math.pi / 180;

  static double _pow(double base, num exponent) => math.pow(base, exponent).toDouble();

  static double _radiansToDegrees(double radians) => radians * 180 / math.pi;

  static String _latitudeToZoneLetter(double latitude) {
    if (latitude >= 84) return 'X';
    if (latitude < -80) return 'C';

    const letters = 'CDEFGHJKLMNPQRSTUVWX';
    final index = ((latitude + 80) / 8).floor().clamp(0, letters.length - 1);
    return letters[index];
  }
}
