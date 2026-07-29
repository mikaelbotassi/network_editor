import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_editor/network_editor.dart';
import 'package:smre_network_client/smre_network_client_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final bounds = LatLngBounds(
    const LatLng(-19.519, -40.639),
    const LatLng(-19.518, -40.638),
  );

  test('requests only layers released at the current zoom', () async {
    final platform = _FakePlatform();
    final controller = NetworkHubOverlayController(
      client: SmreNetworkClient(platform: platform),
    );
    addTearDown(controller.dispose);

    await controller.loadViewport(bounds: bounds, zoom: 14.9);

    expect(platform.requestedLayerCodes, isNotEmpty);
    expect(
      platform.requestedLayerCodes.every(
        (codes) => _sameCodes(codes, const [1, 2]),
      ),
      isTrue,
    );
    expect(controller.features.map((feature) => feature.layer).toSet(), {
      NetworkLayer.redePrimaria,
      NetworkLayer.redeSecundaria,
    });
  });

  test('deduplicates features repeated by neighboring tiles', () async {
    final platform = _FakePlatform();
    final controller = NetworkHubOverlayController(
      client: SmreNetworkClient(platform: platform),
    );
    addTearDown(controller.dispose);

    await controller.loadViewport(bounds: bounds, zoom: 17);

    expect(controller.features.length, NetworkLayer.values.length);
    expect(
      controller.features.map((feature) => feature.layer).toSet(),
      NetworkLayer.values.toSet(),
    );
  });

  test('reloads the viewport after hiding a layer', () async {
    final platform = _FakePlatform();
    final controller = NetworkHubOverlayController(
      client: SmreNetworkClient(platform: platform),
      initialVisibleLayers: {NetworkLayer.redePrimaria, NetworkLayer.poste},
    );
    addTearDown(controller.dispose);

    await controller.loadViewport(bounds: bounds, zoom: 17);
    await controller.setLayerVisible(NetworkLayer.poste, false);

    expect(platform.requestedLayerCodes.last, [1]);
    expect(controller.features.map((feature) => feature.layer).toSet(), {
      NetworkLayer.redePrimaria,
    });
  });

  test('does not query the Hub below every minimum zoom', () async {
    final platform = _FakePlatform();
    final controller = NetworkHubOverlayController(
      client: SmreNetworkClient(platform: platform),
    );
    addTearDown(controller.dispose);

    await controller.loadViewport(bounds: bounds, zoom: 10.9);

    expect(platform.requestedLayerCodes, isEmpty);
    expect(controller.features, isEmpty);
  });
}

bool _sameCodes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var index = 0; index < left.length; index++) {
    if (left[index] != right[index]) return false;
  }
  return true;
}

class _FakePlatform extends SmreNetworkClientPlatform {
  final List<List<int>> requestedLayerCodes = [];

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<Uint8List> readTile({
    required int zoom,
    required int x,
    required int y,
    required List<int> layerCodes,
  }) async {
    requestedLayerCodes.add(List.of(layerCodes));

    return Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'version': 1,
          'tile': {'z': zoom, 'x': x, 'y': y},
          'layers': [
            for (final code in layerCodes)
              {
                'type': code,
                'name': 'layer_$code',
                'features': [
                  {
                    'id': code,
                    'geometry': code <= 2
                        ? {
                            'type': 'LineString',
                            'coordinates': [
                              [-40.639, -19.519],
                              [-40.638, -19.518],
                            ],
                          }
                        : {
                            'type': 'Point',
                            'coordinates': [-40.6385, -19.5185],
                          },
                    'properties': {'title': 'Feature $code'},
                  },
                ],
              },
          ],
        }),
      ),
    );
  }
}
