import 'package:electric_shapes/electric_shapes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

extension NetworkHubLayerStyle on hub.NetworkLayer {
  String get label => switch (this) {
    hub.NetworkLayer.redePrimaria => 'Rede primária',
    hub.NetworkLayer.redeSecundaria => 'Rede secundária',
    hub.NetworkLayer.poste => 'Postes',
    hub.NetworkLayer.transformador => 'Transformadores',
    hub.NetworkLayer.seccionadora => 'Seccionadoras',
    hub.NetworkLayer.capacitora => 'Capacitores',
    hub.NetworkLayer.reguladora => 'Reguladores',
    hub.NetworkLayer.conjuntoMedicao => 'Medição',
  };

  Color get mapColor => switch (this) {
    hub.NetworkLayer.redePrimaria => const Color(0xFFDC2626),
    hub.NetworkLayer.redeSecundaria => const Color(0xFF2563EB),
    hub.NetworkLayer.poste => const Color(0xFF475569),
    hub.NetworkLayer.transformador => const Color(0xFFF59E0B),
    hub.NetworkLayer.seccionadora => const Color(0xFFEF4444),
    hub.NetworkLayer.capacitora => const Color(0xFF10B981),
    hub.NetworkLayer.reguladora => const Color(0xFF8B5CF6),
    hub.NetworkLayer.conjuntoMedicao => const Color(0xFF0891B2),
  };

  IconData get icon => switch (this) {
    hub.NetworkLayer.redePrimaria => ElectricIcons.redeMediaTensaoExistente,
    hub.NetworkLayer.redeSecundaria => ElectricIcons.redeBaixaTensaoExistente,
    hub.NetworkLayer.poste => ElectricIcons.posteConcretoCircularExistente,
    hub.NetworkLayer.transformador => ElectricIcons.transformadorExistente,
    hub.NetworkLayer.seccionadora => ElectricIcons.chaveFusivelExistente,
    hub.NetworkLayer.capacitora => ElectricIcons.capacitora,
    hub.NetworkLayer.reguladora => ElectricIcons.reguladoraExistente,
    hub.NetworkLayer.conjuntoMedicao => Icons.speed_outlined,
  };

  double get iconSize => switch (this) {
    hub.NetworkLayer.capacitora => 26.0,
    hub.NetworkLayer.reguladora => 26.0,
    _ => 18.0,
  };

  double get lineWidth => switch (this) {
    hub.NetworkLayer.redePrimaria => 3.2,
    hub.NetworkLayer.redeSecundaria => 2.4,
    _ => 2,
  };

  double get pointRadius => switch (this) {
    hub.NetworkLayer.poste => 3.5,
    _ => 5.5,
  };

  StrokePattern get strokePattern => switch (this) {
    hub.NetworkLayer.redePrimaria => StrokePattern.dashed(segments: const [8, 6]),
    _ => const StrokePattern.solid(),
  };
}
