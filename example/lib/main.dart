import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:electric_digital_sketch/electric_digital_sketch.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NetworkEditorController(
      showDarkBackground: true,
      initialCenter: const LatLng(-19.5356, -40.6306),
      initialZoom: 17,
      baseTileLayer: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.example.electric_digital_sketch_example',
        maxNativeZoom: 19,
      ),
      initialValue: NetworkEditorValue(
        nodes: [
          EditorNode(
            id: '1',
            svgPath: 'assets/icons/poste-terra.svg',
            groupId: 'pole',
            latitude: -19.5356,
            longitude: -40.6306,
            label: 'Poste 1',
          ),
          EditorNode(
            id: '2',
            groupId: 'pole',
            latitude: -19.5360,
            longitude: -40.6298,
            label: 'Poste 2',
          ),
        ],
        segments: [
          EditorSegment(
            id: 's1',
            groupId: 'rede-primaria',
            fromNodeId: '1',
            toNodeId: '2',
            points: [
              EditorCoordinate(latitude: -19.5356, longitude: -40.6306),
              EditorCoordinate(latitude: -19.5360, longitude: -40.6298),
            ],
          ),
        ],
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: NetworkEditorWidget(controller: controller),
        ),
      ),
    );
  }
}