import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:network_editor/network_editor.dart';
import 'package:network_editor_example/src/entities/add_pole_interaction.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = NetworkEditorController(
      initialCenter: const LatLng(-19.5356, -40.6306),
      initialZoom: 17,
      baseTileLayer: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'br.com.mikaelbotassi.networkeditorexample',
        maxNativeZoom: 19,
      ),
      customModes: {
        EditorMode.custom(value: 'add_pole', icon: Icons.add, label: 'Novo poste') : AddPoleInteraction()
      },
      initialValue: NetworkEditorValue(
        nodes: [
          EditorNode(
            id: '1',
            svgPath: 'assets/icons/poste-terra.svg',
            color: NetworkEditorDefaultMarkerStyles.blue.fillColor,
            groupId: 'pole',
            latitude: -19.5356,
            longitude: -40.6306,
            label: 'Poste 1',
          ),
          EditorNode(
            id: '2',
            groupId: 'pole',
            color: NetworkEditorDefaultMarkerStyles.blue.fillColor,
            latitude: -19.5360,
            longitude: -40.6298,
            label: 'Poste 2',
          ),
        ],
        segments: [
          EditorSegment(
            id: 's1',
            groupId: 'rede-primaria',
            strokeWidth: 4,
            color: NetworkEditorDefaultSegmentStyles.blueBold.color,
            pattern: NetworkEditorDefaultSegmentStyles.blueBold.strokePattern,
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
          child: NetworkEditorWidget(
            controller: controller,
          ),
        ),
      ),
    );
  }
}