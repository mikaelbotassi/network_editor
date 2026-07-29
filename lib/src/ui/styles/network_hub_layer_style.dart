import 'package:flutter/material.dart';
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
    hub.NetworkLayer.redePrimaria => Icons.account_tree_outlined,
    hub.NetworkLayer.redeSecundaria => Icons.cable_outlined,
    hub.NetworkLayer.poste => Icons.signpost_outlined,
    hub.NetworkLayer.transformador => Icons.electric_bolt_outlined,
    hub.NetworkLayer.seccionadora => Icons.power_settings_new_outlined,
    hub.NetworkLayer.capacitora => Icons.battery_charging_full_outlined,
    hub.NetworkLayer.reguladora => Icons.tune_outlined,
    hub.NetworkLayer.conjuntoMedicao => Icons.speed_outlined,
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
}
