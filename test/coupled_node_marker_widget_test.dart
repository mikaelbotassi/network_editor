import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:network_editor/network_editor.dart';

void main() {
  test('calculateMarkerSize and calculateOrbitRadius provide clean scaling', () {
    expect(CoupledNodeMarkerWidget.calculateMarkerSize(0), 38.0);

    final size1 = CoupledNodeMarkerWidget.calculateMarkerSize(1);
    final size4 = CoupledNodeMarkerWidget.calculateMarkerSize(4);
    final size8 = CoupledNodeMarkerWidget.calculateMarkerSize(8);
    final size9 = CoupledNodeMarkerWidget.calculateMarkerSize(9);

    expect(size1, 104.0);
    expect(size4, 104.0);
    expect(size8, 104.0);
    expect(size9, greaterThan(size8));

    expect(CoupledNodeMarkerWidget.calculateOrbitRadius(1), 35.0);
    expect(CoupledNodeMarkerWidget.calculateOrbitRadius(8), 35.0);
    expect(CoupledNodeMarkerWidget.calculateOrbitRadius(9), greaterThan(35.0));
  });

  testWidgets('renders single feature without orbit track', (tester) async {
    final poleFeature = NetworkFeature(
      id: 1,
      layer: NetworkLayer.poste,
      geometry: const NetworkPointGeometry(
        NetworkCoordinate(latitude: -19.5, longitude: -40.6),
      ),
      properties: const {'title': 'Poste 1'},
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CoupledNodeMarkerWidget.fromFeatures(
              features: [poleFeature],
            ),
          ),
        ),
      ),
    );

    // No CustomPaint with orbit painter when there are no satellites
    expect(
      find.byWidgetPredicate((w) => w is CustomPaint && w.painter is OrbitPainter),
      findsNothing,
    );
    // Center node is rendered
    expect(find.byType(Container), findsWidgets);
  });

  testWidgets('renders coupled node with center pole and satellite badges', (tester) async {
    final pole = NetworkFeature(
      id: 1,
      layer: NetworkLayer.poste,
      geometry: const NetworkPointGeometry(
        NetworkCoordinate(latitude: -19.5, longitude: -40.6),
      ),
      properties: const {'title': 'Poste #1'},
    );

    final transformer = NetworkFeature(
      id: 2,
      layer: NetworkLayer.transformador,
      geometry: const NetworkPointGeometry(
        NetworkCoordinate(latitude: -19.5, longitude: -40.6),
      ),
      properties: const {'title': 'Trafo #2'},
    );

    final switchCutout = NetworkFeature(
      id: 3,
      layer: NetworkLayer.seccionadora,
      geometry: const NetworkPointGeometry(
        NetworkCoordinate(latitude: -19.5, longitude: -40.6),
      ),
      properties: const {'title': 'Chave #3'},
    );

    final tapped = <NetworkFeature>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CoupledNodeMarkerWidget.fromFeatures(
              features: [pole, transformer, switchCutout],
              onFeatureTap: (f) => tapped.add(f),
            ),
          ),
        ),
      ),
    );

    // Orbit track is drawn
    expect(
      find.byWidgetPredicate((w) => w is CustomPaint && w.painter is OrbitPainter),
      findsOneWidget,
    );

    // Icons of transformer and switch should be found
    expect(find.byIcon(NetworkLayer.transformador.icon), findsOneWidget);
    expect(find.byIcon(NetworkLayer.seccionadora.icon), findsOneWidget);

    // Tap on the transformer satellite icon
    await tester.tap(find.byIcon(NetworkLayer.transformador.icon));
    expect(tapped.length, 1);
    expect(tapped.first.id, 2);
    expect(tapped.first.layer, NetworkLayer.transformador);

    // Tap on the switch satellite icon
    await tester.tap(find.byIcon(NetworkLayer.seccionadora.icon));
    expect(tapped.length, 2);
    expect(tapped.last.id, 3);
    expect(tapped.last.layer, NetworkLayer.seccionadora);
  });
}
