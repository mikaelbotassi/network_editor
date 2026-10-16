import 'package:flutter/material.dart';
import 'package:electric_shapes/electric_shapes.dart';
import 'package:network_editor/src/domain/enums/tipo_poste.dart';
import 'package:smre_network_client/smre_network_client.dart' as hub;

extension NetworkHubFeatureStyle on hub.NetworkFeature {
  IconData get icon {
    switch (layer) {
      case hub.NetworkLayer.redePrimaria:
        return ElectricIcons.redeMediaTensaoExistente;
      case hub.NetworkLayer.redeSecundaria:
        return ElectricIcons.redeBaixaTensaoExistente;
      case hub.NetworkLayer.poste:
        final tipo = properties['tipo'] as int? ?? 5;
        return TipoPoste.fromValue(tipo).icon;
      case hub.NetworkLayer.transformador:
        return ElectricIcons.transformadorExistente;
      case hub.NetworkLayer.seccionadora:
        return ElectricIcons.chaveFusivelExistente;
      case hub.NetworkLayer.capacitora:
        return ElectricIcons.capacitora;
      case hub.NetworkLayer.reguladora:
        return ElectricIcons.reguladoraExistente;
      case hub.NetworkLayer.conjuntoMedicao:
        return Icons.speed_outlined;
    }
  }
}
